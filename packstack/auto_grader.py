import subprocess
import re
import sys
from typing import Dict, List

def parse_markdown(file_path: str) -> Dict[str, List[str]]:
    """解析RHCE实验文档中的代码块和考核要求"""
    sections = {}
    current_section = ''
    
    with open(file_path, 'r', encoding='utf-8') as f:
        for line in f:
            if line.startswith('## '):
                current_section = line.strip().split(' ', 2)[-1]
                sections[current_section] = []
            elif line.startswith('```'):
                code_block = []
                while True:
                    line = next(f)
                    if line.startswith('```'):
                        break
                    code_block.append(line)
                sections[current_section].append(''.join(code_block))
    return sections

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

def main():
    if len(sys.argv) < 2:
        print("Usage: python auto_grader.py <markdown_file>")
        sys.exit(1)
    
    lab_sections = parse_markdown(sys.argv[1])
    
    # 系统初始化配置验证
    if '系统初始化配置' in lab_sections:
        required_users = [f'ops0{i}' for i in range(1,6)]
        user_check = check_user_permissions(required_users)
        firewall_check = check_firewall_rules()
        
        print(f"用户权限验证结果: {'通过' if user_check else '失败'}")
        print(f"防火墙配置验证结果: {'通过' if firewall_check else '失败'}")
        
        # 初始化计分系统
        total_score = 0
        scoring_rules = {
            '用户权限': {'weight': 0.4, 'passed': user_check},
            '防火墙配置': {'weight': 0.3, 'passed': firewall_check},
            'Ansible部署': {'weight': 0.2, 'passed': verify_ansible_deployment()},
            '容器状态': {'weight': 0.1, 'passed': check_container_status('httpd')}
        }
        
        # 计算总分并生成报告
        total_score = sum(rule['weight'] * 100 for rule in scoring_rules.values() if rule['passed'])
        print(f"\n{'='*30} 考核报告 {'='*30}")
        for category, data in scoring_rules.items():
            status = '✓' if data['passed'] else '✗'
            print(f"{category.ljust(10)} | 权重:{data['weight']} | 状态: {status}")
        print(f"{'='*70}\n最终得分: {total_score:.1f}/100")

if __name__ == '__main__':
    main()