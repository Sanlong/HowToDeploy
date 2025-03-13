#!/bin/bash

# 检查root权限
if [[ $EUID -ne 0 ]]; then
   echo -e "\033[31m请使用root权限运行此脚本！\033[0m"
   exit 1
fi

# 检测操作系统类型
detect_os() {
    # 获取发行版名称和版本号
    if grep -qEi "ubuntu" /etc/os-release; then
        distro="ubuntu"
        version=$(grep 'VERSION_ID' /etc/os-release | cut -d '\"' -f2 | cut -d '.' -f1)
    elif grep -qEi "debian" /etc/os-release; then
        distro="debian"
        version=$(grep 'VERSION_ID' /etc/os-release | cut -d '\"' -f2 | cut -d '.' -f1)
    elif grep -qEi "centos" /etc/os-release; then
        distro="centos"
        version=$(grep 'VERSION_ID' /etc/os-release | cut -d '\"' -f2 | cut -d '.' -f1)
    else
        echo -e "\033[31m不支持的操作系统\033[0m"
        exit 1
    fi

    # 定义EOL版本清单（示例数据）
    declare -A EOL_VERSIONS=(
        [ubuntu:16]=1
        [debian:9]=1
        [centos:6]=1
        [centos:7]=1  # 示例：假设CentOS 7已EOL
    )

    if [[ -n "${EOL_VERSIONS[$distro:$version]}" ]]; then
        echo -e "\033[31m警告：检测到 $distro $version 已结束生命周期支持\033[0m"
        read -p "是否继续安装？(y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    # 原始操作系统类型判断
    if [[ "$distro" == "ubuntu" || "$distro" == "debian" ]]; then
        echo "debian"
    else
        echo "rhel"
    fi
}

# 事务管理变量
declare -a ROLLBACK_STACK
CURRENT_STAGE=0

# 事务回滚函数
rollback() {
    echo -e "\033[31m开始回滚操作...\033[0m"
    while [[ ${#ROLLBACK_STACK[@]} -gt 0 ]]; do
        case ${ROLLBACK_STACK[-1]} in
            1)
                echo "回滚: 删除临时文件"
                rm -f /tmp/zabbix_*.list
                ;;
            2)
                case $os_type in
                    debian)
                        echo "回滚: 卸载Zabbix软件包"
                        apt purge -y $(cat /tmp/zabbix_packages.list)
                        ;;
                    rhel)
                        echo "回滚: 卸载Zabbix软件包"
                        yum remove -y $(cat /tmp/zabbix_packages.list)
                        ;;
                esac
                ;;
            3)
                echo "回滚: 删除数据库"
                mysql -e "DROP DATABASE IF EXISTS zabbix; DROP USER IF EXISTS zabbix@localhost;"
                ;;
            4)
                echo "回滚: 恢复配置文件"
                cp /etc/zabbix/zabbix_server.conf.bak /etc/zabbix/zabbix_server.conf
                ;;
        esac
        unset 'ROLLBACK_STACK[${#ROLLBACK_STACK[@]}-1]'
    done
    exit 1
}

# 错误处理函数
error_handler() {
    echo -e "\033[31m\n在阶段 $CURRENT_STAGE 发生错误！\033[0m"
    read -p "是否要回退到安装前状态？(y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rollback
    else
        exit 1
    fi
}

trap 'error_handler' ERR

# 安装Zabbix及其依赖
install_zabbix() {
    CURRENT_STAGE=2
    case $1 in
        debian)
            apt update || return 1
            apt install -y mysql-server apache2 php libapache2-mod-php \
                php-mysql php-gd php-bcmath php-mbstring php-xml || return 1
            wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb || return 1
            dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb || return 1
            apt update || return 1
            apt install -y zabbix-server-mysql zabbix-frontend-php \
                zabbix-apache-conf zabbix-sql-scripts zabbix-agent || return 1
            # 记录安装包列表
            dpkg -l | grep zabbix | awk '{print $2}' > /tmp/zabbix_packages.list
            ROLLBACK_STACK+=(2)
            ;;
        rhel)
            yum install -y mariadb-server httpd php php-mysqlnd \
                php-gd php-bcmath php-mbstring php-xml tar gzip || return 1
            rpm -Uvh --nodeps \
                https://repo.zabbix.com/zabbix/6.4/rhel/9/x86_64/zabbix-release-6.4-1.el9.noarch.rpm || return 1
            yum install -y zabbix-server-mysql zabbix-web-mysql \
                zabbix-apache-conf zabbix-sql-scripts zabbix-agent zabbix-get || return 1
            # 记录安装包列表
            rpm -qa | grep zabbix > /tmp/zabbix_packages.list
            ROLLBACK_STACK+=(2)
            ;;
    esac
    ROLLBACK_STACK+=(1)
}

# 配置数据库
configure_database() {
    CURRENT_STAGE=3
    /usr/bin/systemctl start mariadb || return 1
    /usr/bin/systemctl enable mariadb || return 1

    mysql <<EOF || return 1
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
CREATE USER zabbix@localhost IDENTIFIED BY 'zabbix_password';
GRANT ALL PRIVILEGES ON zabbix.* TO zabbix@localhost;
FLUSH PRIVILEGES;
EOF
    ROLLBACK_STACK+=(3)
}

# 导入初始数据
import_initial_data() {
    CURRENT_STAGE=4
    case $1 in
        debian) local sql_path=/usr/share/zabbix-sql-scripts/mysql/server.sql.gz ;;
        rhel) local sql_path=$(find /usr/share -name "create.sql.gz" -print -quit) ;;
    esac
    zcat $sql_path | mysql -u zabbix -pzabbix_password zabbix
}

# 配置Zabbix服务端
configure_zabbix_server() {
    CURRENT_STAGE=5
    cp /etc/zabbix/zabbix_server.conf /etc/zabbix/zabbix_server.conf.bak
    echo -e "\nDBPassword=zabbix_password" >> /etc/zabbix/zabbix_server.conf
    sed -i "s/; php_value\[date\.timezone\] = Europe\/Riga/php_value[date.timezone] = Asia\/Shanghai/" \
        /etc/zabbix/apache.conf
    ROLLBACK_STACK+=(4)
}

# 启动服务
start_services() {
    services=(zabbix-server zabbix-agent httpd)
    for service in "${services[@]}"; do
        systemctl restart $service
        systemctl enable $service
    done
}

# 配置防火墙
configure_firewall() {
    if command -v ufw &> /dev/null; then
        ufw allow 80/tcp
        ufw allow 10050/tcp
        ufw allow 10051/tcp
    elif command -v firewall-cmd &> /dev/null; then
        firewall-cmd --permanent --add-service={http,zabbix-agent,zabbix-server}
        firewall-cmd --reload
    fi
}

# 主流程
os_type=$(detect_os)
install_zabbix $os_type
configure_database
import_initial_data $os_type
configure_zabbix_server
start_services
configure_firewall

echo -e "\n\033[32m部署完成！请通过浏览器访问：\033[0m"
echo "http://<服务器IP>/zabbix"
echo -e "\n\033[32m初始登录凭证：\033[0m"
echo "用户名: Admin"
echo "密码: zabbix"