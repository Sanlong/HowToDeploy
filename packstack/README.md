# HowToDeploy

my personal installer steps
1、安装前的要求：
系统源没有的rpm包（在rpmfind.net网站找到centos stream 9）：
python3-lesscpy
fontawesome-fonts-web（版本 >= 4.1.0）
python3-pyxattr
2、安装centos-release-openstack-antelope
3、selinux不能enforce、关闭防火墙
4、禁用 NetworkManager 并启用传统的网络服务：
BASH
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
sudo systemctl enable network
sudo systemctl start network




3、生成应答文件

要安装时间同步服务；不知道是被部署的机器还是packstack所在机器
sudo yum install chrony -y
sudo systemctl enable chronyd
sudo systemctl start chronyd




部署完成后的使用说明
keystonerc_admin 文件已创建
说明：/root/keystonerc_admin 文件包含了 OpenStack 命令行工具所需的认证信息。
使用方法：
使用以下命令加载环境变量：
BASH
source /root/keystonerc_admin
加载后，你可以使用 OpenStack CLI 工具（如 openstack、nova、neutron 等）。