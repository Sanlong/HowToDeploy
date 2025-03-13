import paramiko
import subprocess
import json
import logging
import datetime
import os
import re
import platform
import time

class SSHConnectionManager:
    def __init__(self, config):
        self.connections = {}
        self.config = config
        self.logger = logging.getLogger('SSHManager')

        # 新增分层配置验证
        if 'controller' not in config or 'nodes' not in config:
            raise ValueError("配置缺少controller或nodes节点")

    def _establish_connection(self, host, credentials, retries=3):
        for attempt in range(retries):
            try:
                client = paramiko.SSHClient()
                client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
                client.connect(host, **credentials)
                self.connections[host] = client
                self.logger.info(f'成功建立{host}连接')
                return
            except Exception as e:
                self.logger.warning(f'{host}连接失败（尝试 {attempt+1}/{retries}）: {str(e)}')
                if attempt == retries - 1:
                    raise
                time.sleep(2)

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

    def _execute_remote_command(self, command: str, retries: int = 3) -> str:
        client = self.connections.get(self.config['controller']['ip'])
        if not client:
            raise ConnectionError(f'控制器连接丢失: {self.config["controller"]["ip"]}')
        for attempt in range(retries):
            try:
                _, stdout, stderr = client.exec_command(command)
                exit_code = stdout.channel.recv_exit_status()
                output = stdout.read().decode().strip()
                error = stderr.read().decode().strip()

                if exit_code != 0:
                    self.logger.error(f'命令执行失败（尝试 {attempt+1}/{retries}）: {command}\n错误: {error}')
                    return f'Command failed with exit code {exit_code}: {error}'

                self.logger.debug(f'成功执行命令: {command}\n输出: {output}')
                return output
            except Exception as e:
                self.logger.warning(f'命令执行异常（尝试 {attempt+1}/{retries}）: {str(e)}')
                if attempt == retries - 1:
                    raise
                self._establish_connection(
                    host=self.config['controller']['ip'],
                    credentials=self.config['controller']['credentials']
                )
                time.sleep(2)
        return 'All retries exhausted, command execution failed'

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
            f"sed -i 's/CONFIG_COMPUTE_HOSTS=.*/CONFIG_COMPUTE_HOSTS={','.join(target_ips)}/' {output_path}",
            f"sed -i 's/CONFIG_NEUTRON_OVS_BRIDGE_IFACES=.*/CONFIG_NEUTRON_OVS_BRIDGE_IFACES={self.config['network_interface']}/' {output_path}"
        ]
        
        for cmd in modify_cmds:
            if not conn:
                raise RuntimeError('主控机SSH连接已断开')
            _, stdout, stderr = conn.exec_command(cmd)
            if stdout.channel.recv_exit_status() != 0:
                raise RuntimeError(f'配置应答文件失败: {stderr.read().decode()}')