#!/bin/bash

# 安装必要的依赖包 这3个包需要在rpmfind.org上找到
sudo yum install -y python3-lesscpy fontawesome-fonts-web python3-pyxattr

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

# 部署完成后，加载 OpenStack 环境变量
source /root/keystonerc_admin