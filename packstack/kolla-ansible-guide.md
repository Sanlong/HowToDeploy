# Kolla-Ansible OpenStack 部署指南 (msl用户虚拟环境版)

## 1. 环境准备
### 1.1 系统要求
- 操作系统: 
  - 主机A(部署执行机): RockyLinux 9.5服务器
  - 主机B(all-in-one节点): RockyLinux 9.5服务器
- 硬件配置: 
  - 主机A: 至少2核CPU, 4GB内存, 20GB磁盘空间(仅用于部署)
  - 主机B: 至少8核CPU, 16GB内存, 100GB磁盘空间(运行所有OpenStack服务)
- 网络: 每台主机至少2个网络接口
- 用户: 两台主机上已创建具有sudo权限的非root用户msl

### 1.2 主机A上的操作
#### 1.2.1 安装依赖
```bash
# 主机A上执行
# 安装基础依赖
sudo dnf install -y epel-release
sudo dnf install -y python3-devel libffi-devel gcc openssl-devel python3-pip python3-virtualenv

# 创建虚拟环境
python3 -m virtualenv ~/kolla-venv
source ~/kolla-venv/bin/activate

# 主机A上执行：添加当前用户到docker组并重启docker服务
sudo usermod -aG docker $USER
sudo systemctl restart docker

# 在虚拟环境中安装kolla-ansible
pip install -U pip
pip install 'docker>=5.0.0'  # 必须安装docker模块才能执行prechecks
pip install kolla-ansible

# 验证kolla-ansible安装路径
find /usr -name kolla-ansible

### 1.3 主机B上的操作
#### 1.3.1 准备主机B
1. 确保主机B已安装RockyLinux 9.5
2. 创建具有sudo权限的用户msl
3. 安装基础依赖:
```bash
sudo dnf install -y epel-release
sudo dnf install -y python3-devel libffi-devel gcc openssl-devel
```

### 1.4 主机B准备
#### 1.4.1 在主机B上执行
```bash
# 安装基础依赖
sudo dnf install -y epel-release
sudo dnf install -y python3-devel libffi-devel gcc openssl-devel python3-pip

# 安装docker
sudo dnf config-manager --add-repo=https://mirrors.huaweicloud.com/docker-ce/linux/centos/docker-ce.repo
sudo sed -i 's+download.docker.com+mirrors.huaweicloud.com/docker-ce+' /etc/yum.repos.d/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io
sudo systemctl enable --now docker

# 创建docker用户组并添加当前用户
sudo groupadd docker
sudo usermod -aG docker $USER
newgrp docker
```
```



## 2. Kolla-Ansible安装
### 2.1 主机A上的操作
#### 2.1.1 在虚拟环境中安装Kolla-Ansible
```bash
# 确保在msl用户的虚拟环境中操作
source ~/kolla-venv/bin/activate

# 安装kolla-ansible
pip install -U pip
pip install 'docker>=5.0.0'
pip install kolla-ansible
```

### 2.2 配置文件准备
```bash
# 复制示例配置文件
sudo cp -r /usr/share/kolla-ansible/etc_examples/kolla /etc/kolla/
sudo cp /usr/share/kolla-ansible/ansible/inventory/* /etc/kolla-ansible/
```

## 3. OpenStack部署
### 3.1 主机A上的操作
#### 3.1.1 配置globals.yml
编辑`/etc/kolla/globals.yml`:
```yaml
kolla_base_distro: "centos"
kolla_install_type: "binary"
openstack_release: "victoria"
# 根据实际网卡名称修改（使用ip addr命令查看）
network_interface: "ens192"       # 管理网络接口
neutron_external_interface: "ens224"  # 外部网络接口
```

### 3.2 部署命令
```bash
# 生成密码
sudo kolla-genpwd

# 预检查
# 配置主机名解析
sudo bash -c 'echo "192.168.0.99 openstack" >> /etc/hosts'

# 安装openstack连接插件
pip install 'ansible>=2.9.0' 'openstacksdk>=0.36.0'

# 正确语法: kolla-ansible prechecks -i <inventory_path>
# 注意: prechecks 是复数形式，不是 precheck
# 重要: 执行prechecks需要sudo权限，请确保当前用户有sudo权限
# 密码传递方式（任选其一）:
# 1. 交互式输入: 添加--ask-become-pass参数
#   示例: sudo kolla-ansible prechecks -i /etc/kolla-ansible/inventory --ask-become-pass
# 2. 直接传递密码: 使用 -e ansible_become_password='密码'（生产环境不推荐）
#   示例: sudo kolla-ansible prechecks -i /etc/kolla-ansible/inventory -e ansible_become_password='your_password'
# 安全建议: 
# - 推荐配置免密码sudo
# - 使用明文传递密码时，务必在测试环境使用并立即清理命令历史
# 1. 编辑sudoers文件: sudo visudo
# 2. 添加配置: username ALL=(ALL) NOPASSWD:ALL
sudo kolla-ansible prechecks -i /etc/kolla-ansible/inventory --ask-become-pass

# 开始部署
# 正确语法: kolla-ansible deploy -i <inventory_path>
# 注意: 必须使用完整的命令路径(如果在虚拟环境中)
~/kolla-venv/bin/kolla-ansible deploy -i /etc/kolla-ansible/inventory
```

## 4. 验证部署
```bash
# 创建admin-openrc文件
kolla-ansible post-deploy
source /etc/kolla/admin-openrc.sh

# 验证服务
openstack service list
openstack compute service list
```

## 5. 常见问题
### 5.1 部署失败处理
- 检查日志: `/var/log/kolla/`
- 重新运行失败的任务: `kolla-ansible -i /etc/kolla-ansible/inventory deploy --tags [tag_name]`

### 5.2 网络问题
- 确保neutron服务正常运行
- 检查防火墙设置

## 6. 后续操作
- 创建第一个项目、用户和网络
- 上传镜像
- 创建安全组规则

## 7. 权限管理
### 7.1 赋予用户对/etc/kolla目录的权限
```bash
# 将目录所有者改为msl用户
sudo chown -R msl:msl /etc/kolla

# 设置目录权限为755（所有者可读写执行，组和其他用户可读执行）
sudo chmod -R 755 /etc/kolla
```

注意：
- 在生产环境中，建议使用更严格的权限设置
- 可以根据实际需求调整用户组和权限设置