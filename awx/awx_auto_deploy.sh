#!/bin/bash

# 检查root权限
if [[ $EUID -ne 0 ]]; then
   echo -e "\033[31m请使用root权限运行此脚本！\033[0m"
   exit 1
fi

# 网络连通性检查
check_os_environment() {
    echo -e "\033[33m正在验证操作系统环境...\033[0m"

    # RockyLinux 软件源配置
    dnf install -y epel-release
    dnf config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    sed -i 's#download.docker.com#mirrors.aliyun.com/docker-ce#g' /etc/yum.repos.d/docker-ce.repo
    # 添加镜像加速器
    mkdir -p /etc/docker
    echo '{"registry-mirrors": ["https://你的阿里云镜像加速地址.mirror.aliyuncs.com"]}' > /etc/docker/daemon.json

    # 验证软件包名称
    required_packages=(
        "curl" 
        "git" 
        "docker-ce" 
        "python39-pip"
    )

    # 检查预装依赖
    required_packages=(
        "curl" 
        "git" 
        "docker-ce" 
        "python3-pip"
    )

    missing_pkgs=()
    for pkg in "${required_packages[@]}"; do
        if ! rpm -q $pkg &>/dev/null; then
            missing_pkgs+=("$pkg")
        fi
    done

    if [[ ${#missing_pkgs[@]} -gt 0 ]]; then
        echo -e "\033[31m缺失必要依赖包：${missing_pkgs[*]}\033[0m"
        echo -e "\033[33m请先执行：dnf install -y ${missing_pkgs[*]}\033[0m"
        exit 1
    fi

    echo -e "\033[32m操作系统环境验证通过！\033[0m\n"
}

check_network() {
    echo -e "\033[33m正在进行网络连通性测试...\033[0m"
    
    # 检查curl是否安装
    if ! command -v curl &> /dev/null; then
        echo -e "\033[33m正在安装curl工具...\033[0m"
        dnf install -y curl || yum install -y curl
    fi
    
    # 测试目标列表（Google、GitHub、Cloudflare）
    targets=(
        "https://www.google.com" 
        "https://github.com" 
        "https://cloudflare.com"
    )
    
    for target in "${targets[@]}"; do
        attempt=1
        while [[ $attempt -le 3 ]]; do
            if curl --connect-timeout 10 -sSf $target >/dev/null; then
                echo -e "\033[32m连通性测试通过：$target\033[0m"
                break
            else
                echo -e "\033[33m第${attempt}次尝试失败：$target\033[0m"
                ((attempt++))
                sleep 2
            fi
            
            if [[ $attempt -gt 3 ]]; then
                echo -e "\033[31m错误：无法连接至$target\033[0m"
                return 1
            fi
        done
    done
}

# 安装基础依赖
install_dependencies() {
    dnf config-manager --set-enabled crb --priority 10
    dnf config-manager --set-enabled baseos --priority 1
    dnf config-manager --set-enabled appstream --priority 1
    dnf install -y git gcc python3-pip python3-devel docker-ce docker-ce-cli containerd.io
}

# 配置容器环境
setup_container_env() {
    systemctl start docker
    systemctl enable docker
    pip3 install docker-compose -i https://pypi.tuna.tsinghua.edu.cn/simple --trusted-host pypi.tuna.tsinghua.edu.cn
}

# 配置SELinux
configure_selinux() {
    dnf install -y policycoreutils-python-utils
    setenforce 0
    sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
    semanage permissive -a httpd_t
}

# 部署AWX
install_awx() {
    local awx_dir="/opt/awx"
    git clone https://github.com/ansible/awx.git $awx_dir
    
    # 生成随机密码
    admin_pass=$(openssl rand -base64 12)
    
    # 配置inventory文件
    cat > $awx_dir/installer/inventory <<EOF
[all:vars]
dockerhub_base=ansible
awx_task_hostname=awx
awx_web_hostname=awxweb
postgres_data_dir=/var/lib/pgdocker
host_port=80

admin_password=$admin_pass

pg_host=postgres
pg_port=5432
pg_database=awx
pg_username=awx
pg_password=awxpass
EOF

    # 运行安装程序
    cd $awx_dir/installer
    ansible-playbook -i inventory install.yml
}

# 主流程
set -e

check_os_environment
    check_network
    install_dependencies
    setup_container_env
    configure_selinux
    install_awx

    echo -e "\n\033[32m部署完成！访问信息：\033[0m"
    echo "AWX URL: http://$(hostname -I | awk '{print $1}')"
    echo "管理员密码: $admin_pass"
trap 'catch $? $LINENO' ERR

catch() {
  echo -e "\033[31m部署错误: $1\033[0m"
  exit 1
}

# 添加执行权限
chmod +x "$0"