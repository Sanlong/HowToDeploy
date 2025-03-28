#!/bin/bash
set -e

# 环境检测
if [ "$(uname)" != "Linux" ]; then
    echo "错误：本脚本仅支持Linux系统"
    exit 1
fi

# 权限检查
if [ $EUID -eq 0 ]; then
    echo "请勿使用root用户运行本脚本"
    exit 1
fi

# 安装依赖
if command -v dnf &> /dev/null; then
    sudo dnf install -y git curl podman podman-compose python3-pip
elif command -v apt &> /dev/null; then
    sudo apt update
    sudo apt install -y git curl podman podman-compose python3-pip
else
    echo "不支持的包管理器"
    exit 1
fi

# 配置镜像加速
mkdir -p ~/.config/containers
cat <<EOF > ~/.config/containers/registries.conf
unqualified-search-registries = ["docker.io", "quay.io"]

[[registry]]
prefix = "docker.io"
location = "docker.m.daocloud.io"

[[registry]]
prefix = "quay.io"
location = "quay.mirrors.ustc.edu.cn"
EOF

# 安装Ansible
sudo pip3 install ansible-core

# 部署AWX
AWX_VERSION="17.1.0"
if [ ! -d "awx" ]; then
    git clone https://github.com/ansible/awx.git
fi
cd awx
git checkout $AWX_VERSION

# 生成配置文件
cat <<EOF > installer/inventory
[docker]
localhost ansible_connection=local

[all:vars]
docker_compose_dir=/usr/bin
docker_compose_command=podman-compose
kubernetes_install=false
postgres_data_dir=/var/lib/awx/pgdocker
awx_data_dir=/var/lib/awx/projects
admin_password=YourSecurePassword123!
EOF

# 执行部署
cd installer
ansible-playbook -i inventory install.yml

# 验证部署
podman ps -a
echo -e "\n部署完成！访问地址：http://$(curl -s ifconfig.me):8052"
echo "用户名：admin，密码：YourSecurePassword123!"