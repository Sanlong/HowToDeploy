# PackStack OpenStack 一键部署指南

## 安装要求
1. 系统要求：CentOS Stream 9
2. 需要提前下载的依赖包：
   - python3-lesscpy
   - fontawesome-fonts-web (版本 >= 4.1.0)
   - python3-pyxattr

## 部署步骤
```bash
# 安装基础依赖
sudo dnf install -y python3-lesscpy fontawesome-fonts-web python3-pyxattr  # 软件包源：
# python3-lesscpy: https://rpmfind.net/rocky/9.5/epel/aarch64/python3-lesscpy-0.15.1-2.el9.noarch.rpm
# fontawesome-fonts-web: https://rpmfind.net/rocky/9.5/appstream/aarch64/fontawesome-fonts-web-4.7.0-11.el9.noarch.rpm
# python3-pyxattr: https://rpmfind.net/rocky/9.5/baseos/aarch64/python3-pyxattr-0.7.2-4.el9.aarch64.rpm

# 安装OpenStack仓库
sudo yum install -y centos-release-openstack-antelope

# 配置系统环境
sudo setenforce 0
sudo systemctl stop firewalld --now
disable_network_manager

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