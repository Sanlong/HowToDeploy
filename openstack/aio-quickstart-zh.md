# OpenStack-Ansible AIO 快速入门指南 (中文版)

## 1. 概述
本文档将指导您如何使用OpenStack-Ansible快速部署一个All-in-One(一体化)的OpenStack环境。

## 2. 系统要求
- 操作系统: Ubuntu 20.04 LTS 或 CentOS 8
- 硬件配置:
  - 至少4核CPU
  - 16GB内存
  - 100GB可用磁盘空间

## 3. 安装步骤
### 3.1 安装依赖
```bash
# Ubuntu系统
sudo apt update
sudo apt install -y git python3-dev python3-pip

# CentOS系统
sudo yum install -y git python3-devel python3-pip
```

### 3.2 克隆仓库
```bash
git clone https://opendev.org/openstack/openstack-ansible
cd openstack-ansible
```

### 3.3 运行引导脚本
```bash
./scripts/bootstrap-ansible.sh
```

### 3.4 配置AIOS环境
```bash
./scripts/bootstrap-aio.sh
```

## 4. 部署OpenStack
```bash
cd /opt/openstack-ansible/playbooks
openstack-ansible setup-everything.yml
```

## 5. 验证安装
```bash
source /opt/openstack-ansible/venvs/openstack-ansible-*/bin/activate
openstack service list
```

## 6. 访问Dashboard
OpenStack Dashboard将可通过以下URL访问:
http://<your-server-ip>/dashboard

## 7. 常见问题
- 如果遇到网络问题，请检查防火墙设置
- 部署失败时，查看/var/log/ansible/目录下的日志文件

## 8. 后续步骤
- 创建第一个项目
- 上传镜像
- 创建网络和安全组