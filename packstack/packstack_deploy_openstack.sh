#!/bin/bash

# 添加错误处理机制
set -e

# 安装必要依赖包（需提前下载到本地）
echo "正在安装基础依赖包..."
sudo dnf install -y https://rpmfind.net/rocky/9.5/epel/aarch64/python3-lesscpy-0.15.1-2.el9.noarch.rpm \
    https://rpmfind.net/rocky/9.5/appstream/aarch64/fontawesome-fonts-web-4.7.0-11.el9.noarch.rpm \
    https://rpmfind.net/rocky/9.5/baseos/aarch64/python3-pyxattr-0.7.2-4.el9.aarch64.rpm || {
    echo "依赖包安装失败，请检查网络连接或包路径";
    exit 1;
}

# 安装 OpenStack Antelope 版本
sudo yum install -y centos-release-openstack-antelope

# 关闭 SELinux 和防火墙
sudo setenforce 0
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# 禁用 NetworkManager 并启用传统网络服务
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo systemctl enable network
sudo systemctl start network

# 安装并配置时间同步服务
sudo yum install -y chrony
sudo systemctl enable chronyd
sudo systemctl start chronyd

# 生成应答文件并部署 OpenStack
packstack --allinone

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi