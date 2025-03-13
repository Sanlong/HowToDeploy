import paramiko
import subprocess
import json
import logging
import datetime
import os
import re

class OpenStackDeployer:
    def __init__(self, config_path=os.path.abspath(os.path.join(os.path.dirname(__file__), 'config.json'))):
        self.load_config(config_path)
        self.logger = self.setup_logger()
        self.ssh = paramiko.SSHClient()
        self.ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    def load_config(self, config_path):
        # 配置文件加载方法
        with open(config_path) as f:
            self.config = json.load(f)

    def setup_logger(self):
        # 日志记录配置
        logger = logging.getLogger('OpenStackDeploy')
        logger.setLevel(logging.DEBUG)
        
        # 创建文件处理器
        file_handler = logging.FileHandler('deployment.log')
        file_handler.setFormatter(logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'))
        
        # 创建控制台处理器
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        
        logger.addHandler(file_handler)
        logger.addHandler(console_handler)
        return logger

    def execute_commands(self):
        try:
            # 主控机环境检查
            self.check_master_environment()
            
            # 生成应答文件
            self.generate_answer_file()
            
            # 执行packstack部署
            deploy_cmd = f"packstack --answer-file={self.config['packstack_answer_file']}"
            result = subprocess.run(
                deploy_cmd.split(),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            if result.returncode != 0:
                self.logger.error(f'OpenStack部署失败: {result.stderr}')
                return False
                
            self.logger.info('OpenStack部署成功！')
            return True
        except Exception as e:
            self.logger.error(f'部署过程异常: {str(e)}')
            return False

    def pre_deployment_checks(self):
        """执行部署前环境检查"""
        checks = [
            ('sestatus | grep -q "disabled\\|permissive"', "SELinux未禁用"),
            ('test -f /etc/yum.repos.d/packstack.repo', "缺少Packstack软件源"),
            ('arch | grep -q x86_64', "架构不匹配"),
            ('egrep -q "^(NAME=\"? (Red Hat Enterprise Linux|CentOS Stream|AlmaLinux|Rocky Linux)\"?|VERSION_ID=\"?9(\\.[0-9]+)?")" /etc/os-release', "操作系统版本不符")
        ]
        
        for cmd, err_msg in checks:
            if self.ssh.exec_command(cmd)[1].channel.recv_exit_status() != 0:
                raise RuntimeError(f"预检失败: {err_msg}")

    def check_master_environment(self):
        """检查主控机packstack安装状态"""
        check_cmd = 'rpm -q openstack-packstack'
        result = subprocess.run(
            check_cmd.split(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        if result.returncode != 0:
            raise RuntimeError('主控机未安装packstack')
        
        # 操作系统版本检查
        _, stdout, _ = self.ssh.exec_command('cat /etc/os-release')
        os_info = stdout.read().decode()
        
        # 使用正则表达式匹配RHEL兼容发行版
        version_match = re.search(r'VERSION_ID="?9(\.[0-9]+)?', os_info)
        
        if not match or not version_match:
            raise RuntimeError('需要RHEL 9.x兼容系统')

    def generate_answer_file(self):
        """根据模板生成应答文件"""
        # 生成带时间戳的应答文件名
        timestamp = datetime.datetime.now().strftime('%Y%m%d%H%M%S')
        output_path = f"{self.config['packstack_answer_file']}_{timestamp}"
        
        # 生成默认应答文件
        gen_cmd = f"packstack --gen-answer-file={output_path}"
        result = subprocess.run(
            gen_cmd.split(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        if result.returncode != 0:
            raise RuntimeError(f'生成默认应答文件失败: {result.stderr.decode()}')
        
        # 读取生成的文件内容进行修改
        with open(output_path, 'r+') as f:
            content = f.read()
            # 替换网络配置参数
            content = content.replace('CONFIG_DEFAULT_PASSWORD=', f'CONFIG_DEFAULT_PASSWORD={self.config["admin_password"]}')
            content = content.replace('CONFIG_CONTROLLER_HOST=', f'CONFIG_CONTROLLER_HOST={self.config["target_ip"]}')
            content = content.replace('CONFIG_COMPUTE_HOSTS=', f'CONFIG_COMPUTE_HOSTS={self.config["compute_nodes"]}')
            # 回写修改后的内容
            f.seek(0)
            f.write(content)
            f.truncate()
        
        self.logger.info(f'已生成版本化应答文件: {output_path}')

if __name__ == '__main__':
    deployer = OpenStackDeployer()
    if deployer.execute_commands():
        print('OpenStack部署成功！')
    else:
        print('部署过程中出现错误，请检查日志')
        # 添加sudo权限检查
        (f'grep -q "CONFIG_SUDOERS_SETUP=.*" {self.config["packstack_answer_file"]}', "应答文件缺少sudo配置参数"),