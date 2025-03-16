import subprocess
import re
import sys
from typing import Dict, List
import logging
import yaml
import os

def parse_markdown(file_path: str) -> Dict[str, List[str]]:
    """解析RHCE实验文档中的代码块和考核要求"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        # 提取代码块
        code_blocks = re.findall(r'```(.+?)```', content, re.DOTALL)
        # 提取要求
        requirements = re.findall(r'## 要求\n(.+?)\n##', content, re.DOTALL)
        return {
            'code_blocks': code_blocks,
            'requirements': requirements
        }
    except Exception as e:
        print(f"解析文档失败: {e}")
        return {'code_blocks': [], 'requirements': []}

def check_firewall_rules() -> bool:
    """验证防火墙服务配置"""
    try:
        permanent_check = subprocess.run(
            ['firewall-cmd', '--permanent', '--list-services'],
            capture_output=True, text=True
        )
        runtime_check = subprocess.run(
            ['firewall-cmd', '--list-services'],
            capture_output=True, text=True
        )
        return 'http' in permanent_check.stdout and 'https' in permanent_check.stdout \
            and 'http' in runtime_check.stdout and 'https' in runtime_check.stdout
    except Exception as e:
        print(f"防火墙检查失败: {e}")
        return False


def verify_ansible_deployment() -> bool:
    """验证Ansible部署结果"""
    try:
        result = subprocess.run(['ansible-playbook', '--check', 'deploy.yml'],
                              capture_output=True, text=True)
        return 'changed=0' in result.stdout and 'unreachable=0' in result.stdout
    except Exception as e:
        print(f"Ansible验证失败: {e}")
        return False


def check_container_status(container_name: str) -> bool:
    """检查容器运行状态"""
    try:
        status = subprocess.run(['podman', 'ps', '--filter', f'name={container_name}', '--format', '{{.Status}}'],
                              capture_output=True, text=True)
        return 'Up' in status.stdout
    except Exception as e:
        print(f"容器状态检查失败: {e}")
        return False


def check_user_permissions(users: List[str]) -> bool:
    """验证用户权限配置"""
    try:
        result = subprocess.run(['getent', 'group', 'sysadmin'], capture_output=True, text=True)
        return all(
            subprocess.run(['id', user], stdout=subprocess.DEVNULL).returncode == 0
            for user in users
        ) and 'sysadmin' in result.stdout
    except Exception as e:
        print(f"用户权限检查失败: {e}")
        return False

class ConfigManager:
    def __init__(self, config_path: str = "config.yml"):
        self.config_path = config_path
        self.config = self._load_config()

    def _load_config(self) -> dict:
        if not os.path.exists(self.config_path):
            default_config = {
                "check_items": {
                    "firewall": True,
                    "ansible": True,
                    "container": True,
                    "users": True
                },
                "container_name": "test-container",
                "required_users": ["user1", "user2"]
            }
            with open(self.config_path, 'w') as f:
                yaml.dump(default_config, f)
            return default_config
        with open(self.config_path) as f:
            return yaml.safe_load(f)

def main():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler('grader.log'),
            logging.StreamHandler()
        ]
    )

    if len(sys.argv) < 2:
        logging.error("请提供markdown文件路径")
        sys.exit(1)
    
    file_path = sys.argv[1]
    results = parse_markdown(file_path)
    
    config = ConfigManager()
    check_items = []
    
    if config.config['check_items']['firewall']:
        check_items.append(check_firewall_rules())
    if config.config['check_items']['ansible']:
        check_items.append(verify_ansible_deployment())
    if config.config['check_items']['container']:
        check_items.append(check_container_status(config.config['container_name']))
    if config.config['check_items']['users']:
        check_items.append(check_user_permissions(config.config['required_users']))
    
    if all(check_items):
        logging.info("所有检查项通过")
        sys.exit(0)
    else:
        logging.warning("存在未通过的检查项")
        sys.exit(1)

if __name__ == '__main__':
    main()