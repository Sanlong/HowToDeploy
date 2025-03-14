# PackStack OpenStack 一键部署指南 | PackStack OpenStack One-Click Deployment Guide

## 安装要求 | Installation Requirements
1. 系统要求：CentOS Stream 9 | System Requirements: CentOS Stream 9
2. 需要提前下载的依赖包 | Required dependencies:
   - python3-lesscpy (Python LESS compiler)
   - fontawesome-fonts-web (版本 >= 4.1.0 | Version >= 4.1.0)
   - python3-pyxattr (Extended attributes support)

## 多语言支持 | Multilingual Support
本项目所有技术文档和脚本注释均采用中英双语格式 | All technical documentation and script comments in this project are bilingual (Chinese-English).
使用竖线分隔双语内容 | Uses vertical bar separator for bilingual content.

## 部署步骤
```bash
# 安装基础依赖
sudo dnf install -y https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/python3-lesscpy-0.14.0-7.el9.noarch.rpm
sudo dnf install -y https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/fontawesome-fonts-web-4.7.0-13.el9.noarch.rpm
sudo dnf install -y https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/python3-pyxattr-0.7.2-4.el9.x86_64.rpm

# 安装OpenStack仓库
sudo yum install -y centos-release-openstack-antelope

# 配置系统环境
sudo setenforce 0
sudo systemctl stop firewalld --now
sudo systemctl disable NetworkManager

# 安装时间同步服务
sudo yum install -y chrony
sudo systemctl enable --now chronyd

# 执行Packstack部署
packstack --allinone
```

## 使用说明
1. 加载环境变量：
```bash
source /root/keystonerc_admin
```
2. 验证部署：
```bash
openstack service list
neutron agent-list
```

## 注意事项
1. 部署完成后请立即修改默认密码
2. 生产环境建议保持chrony时间同步服务运行
3. 网络配置需通过nmcli或手动编辑ifcfg文件实现