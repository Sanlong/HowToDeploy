# -*- coding: utf-8 -*-
# 这是一个用于在openEuler 24.03 LTS上部署Ansible Tower的Python脚本。

import subprocess


def run_command(command):
    """运行Shell命令"""
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout, stderr = process.communicate()
    if process.returncode != 0:
        raise Exception(f"命令执行失败: {stderr.decode()}")
    return stdout.decode()


def install_dependencies():
    """安装必要的依赖"""
    print("正在安装必要的依赖...")
    run_command("sudo yum update -y")
    run_command("sudo yum install -y epel-release")
    run_command("sudo yum install -y python3-pip")
    run_command("sudo pip3 install ansible")


def download_ansible_tower():
    """下载Ansible Tower"""
    print("正在下载Ansible Tower...")
    run_command("wget https://releases.ansible.com/ansible-tower/setup/ansible-tower-setup-latest.tar.gz")
    run_command("tar xvfz ansible-tower-setup-latest.tar.gz")
    run_command("cd ansible-tower-setup-*/ && sudo ./setup.sh")


def main():
    """主函数"""
    try:
        install_dependencies()
        download_ansible_tower()
        print("Ansible Tower部署完成！")
    except Exception as e:
        print(f"部署过程中发生错误: {e}")


if __name__ == '__main__':
    main()
