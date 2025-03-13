import paramiko
import subprocess
import json
import logging
import datetime
import os
import re
import platform
import time

from typing import Callable, TypeVar, Any, ParamSpec, Concatenate
from functools import wraps

T = TypeVar('T', bound='SSHConnectionManager')
P = ParamSpec('P')
from remote_deploy.utils.error_handler import retry, handle_ssh_errors

class SSHConnectionManager:
    def __init__(self, config):
        self.connections = {}
        self.config = config
        self.logger = logging.getLogger('SSHManager')

        # 新增分层配置验证
        if 'controller' not in config or 'nodes' not in config:
            raise ValueError("配置缺少controller或nodes节点")

    @handle_ssh_errors
    @retry(max_retries=3)
    def _establish_connection(self, host, credentials):
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(host, **credentials)
        self.connections[host] = client

    def connect_all(self):
        # 使用统一的连接方法建立主控机连接
        self._establish_connection(
            host=self.config['controller']['ip'],
            credentials=self.config['controller']['credentials']
        )
        
        # 使用默认凭证连接所有计算节点
        for node in self.config['nodes']:
            self._establish_connection(
                host=node['ip'],
                credentials=node.get('credentials', self.config['node_defaults'])
            )

    # 新增连接验证装饰器
    @classmethod
    def connection_required(cls, retries: int = 3, delay: int = 2) -> Callable[[Callable[[T, Any], Any]], Callable[[T, Any], Any]]:
        def decorator(func: Callable[[T, Any], Any]) -> Callable[[T, Any], Any]:
            @wraps(func)
            def wrapper(self: T, *args, **kwargs) -> Any:
                for attempt in range(retries):
                    try:
                        host = self.config['controller']['ip']
                        if not self.connections.get(host):
                            self._establish_connection(host, self.config['controller']['credentials'])
                        return func(self, *args, **kwargs)
                    except Exception as e:
                        self.logger.warning(f'连接验证失败（尝试 {attempt+1}/{retries}）: {str(e)}')
                        if attempt == retries - 1:
                            raise
                        time.sleep(delay)
                return func(self, *args, **kwargs)
            return wrapper
        return decorator

    @handle_ssh_errors
    @retry()
    def _execute_remote_command(self, command: str) -> str:
        client = self.connections[self.config['controller']['ip']]
        _, stdout, stderr = client.exec_command(command)
        exit_code = stdout.channel.recv_exit_status()
        output = stdout.read().decode().strip()
        error = stderr.read().decode().strip()

        if exit_code != 0:
            raise RuntimeError(f'命令执行失败: {command}\n错误: {error}')
        
        self.logger.debug(f'成功执行命令: {command}\n输出: {output}')
        return output

    def generate_answer_file(self, conn):
        # 生成带时间戳的应答文件名
        timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
        output_path = f"{self.config['packstack_answer_file']}_{timestamp}"
        
        # 在主控机生成应答文件
        gen_cmd = f"packstack --gen-answer-file={output_path}"
        if not conn:
            raise RuntimeError('主控机SSH连接已断开')
        _, stdout, stderr = conn.exec_command(gen_cmd)
        if stdout.channel.recv_exit_status() != 0:
            raise RuntimeError(f'生成应答文件失败: {stderr.read().decode()}')
        
        # 配置目标机网络参数
        target_ips = [node['ip'] for node in self.config['target_nodes']]
        
        modify_cmds = [
            f"sed -i -e 's/CONFIG_COMPUTE_HOSTS=.*/CONFIG_COMPUTE_HOSTS={','.join(target_ips)}/' "
            f"-e 's/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=.*/CONFIG_NEUTRON_OVS_BRIDGE_IFACES={self.config['network_interface']}/' {output_path}"
        ]
        
        for cmd in modify_cmds:
            if not conn:
                raise RuntimeError('主控机SSH连接已断开')
            _, stdout, stderr = conn.exec_command(cmd)
            if stdout.channel.recv_exit_status() != 0:
                raise RuntimeError(f'配置应答文件失败: {stderr.read().decode()}')