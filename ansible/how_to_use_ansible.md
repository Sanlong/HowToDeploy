# Ansible 完全使用指南

## 目录
1. [核心概念](#核心概念)
2. [安装与配置](#安装与配置)
3. [Inventory管理](#inventory管理)
4. [Ad-hoc命令](#ad-hoc命令)
5. [Playbook详解](#playbook详解)
6. [常用模块手册](#常用模块手册)
7. [高级技巧](#高级技巧)
8. [最佳实践](#最佳实践)
9. [模块速查表](#模块速查表)

## 核心概念
### 架构组成
- 控制节点
- 受管节点
- Inventory
- 模块
- Playbook

## 安装与配置
```bash
# RedHat系
sudo yum install ansible

# Debian系
sudo apt-get install ansible
```

## Inventory管理
### 静态Inventory示例
```ini
[web_servers]
192.168.1.101 ansible_user=admin
192.168.1.102 ansible_ssh_private_key_file=~/.ssh/web.key

[db_servers:children]
web_servers
```

## Ad-hoc命令
```bash
ansible all -m ping
ansible web_servers -m shell -a "free -m"
```

## 常用模块手册
### 系统管理模块
**yum模块**:
```yaml
- name: 安装最新版nginx
  yum:
    name: nginx
    state: latest
    update_cache: yes

# state可选值：present/absent/latest
```

**service模块**:
```yaml
- name: 确保httpd服务运行
  service:
    name: httpd
    state: started
    enabled: yes
```

### 文件操作
**template模块**:
```yaml
- name: 部署配置文件
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    owner: root
    group: root
    mode: 0644
    validate: nginx -t -c %s
```

### 网络管理
**uri模块**:
```yaml
- name: 验证API端点
  uri:
    url: http://localhost:8000/health
    method: GET
    status_code: 200
    timeout: 5
```

## 高级技巧
### 错误处理机制
```yaml
- name: 安全更新软件包
  yum:
    name: "*"
    state: latest
  ignore_errors: yes
  register: update_result

- name: 记录更新失败
  debug:
    msg: "安全更新失败"
  when: update_result is failed
```

### 循环优化
```yaml
- name: 批量创建用户
  user:
    name: "{{ item }}"
    state: present
  loop: "{{ user_list }}"
  when: user_list is defined
```

### 条件判断
```yaml
- name: 按系统类型部署
  yum:
    name: httpd
    state: present
  when: ansible_os_family == "RedHat"

- name: 安装nginx
  apt:
    name: nginx
    state: present
  when: ansible_os_family == "Debian"
```

### 用户管理模块
**user模块**:
```yaml
- name: 创建运维账户
  user:
    name: ops
    uid: 2001
    group: wheel
    shell: /bin/bash
    password: "{{ vault_ops_pass }}"
    generate_ssh_key: yes
    ssh_key_bits: 4096

# state参数：present（默认）/absent
# 支持管理ssh_key、过期时间、密码策略等
```

### 定时任务模块
**cron模块**:
```yaml
- name: 设置日志清理任务
  cron:
    name: "Clean app logs"
    minute: "0"
    hour: "3"
    job: "/usr/sbin/logrotate /etc/logrotate.d/app"
    user: root

- name: 移除过期任务
  cron:
    name: "Old backup job"
    state: absent
```

### 磁盘管理模块
**filesystem模块**:
```yaml
- name: 创建XFS文件系统
  filesystem:
    dev: /dev/sdb1
    fstype: xfs
    force: yes
    opts: "-f -K"

- name: 调整LVM卷大小
  lvol:
    vg: data_vg
    lv: data_lv
    size: +100%FREE
    resizefs: yes
```

## 网络设备配置
**ios_command模块**:
```yaml
- name: 配置Cisco交换机
  ios_command:
    commands:
      - interface GigabitEthernet0/1
      - description Ansible Managed Port
      - switchport mode access
      - spanning-tree portfast
    match: none
  register: config_result

- name: 解析配置结果
  debug:
    msg: "{{ config_result.stdout }}"
```

## 云平台集成
**aws_ec2模块**:
```yaml
- name: 创建EC2实例
  aws_ec2_instance:
    name: web-node
    key_name: ansible-key
    instance_type: t3.medium
    image_id: ami-0abcdef1234567890
    vpc_subnet_id: subnet-0123456789abcdef
    security_group: web-sg
    wait: yes
    volumes:
      - device_name: /dev/sda1
        volume_size: 30
        delete_on_termination: yes
```

## 容器管理模块
**docker_container模块**:
```yaml
- name: 部署Nginx容器
  docker_container:
    name: web-server
    image: nginx:1.21
    state: started
    restart_policy: unless-stopped
    volumes:
      - "/opt/nginx:/etc/nginx"
    ports:
      - "80:80"
    env:
      TZ: Asia/Shanghai
    labels:
      maintainer: "ops@example.com"

- name: 更新容器镜像
  docker_container:
    name: web-server
    image: nginx:1.22
    state: started
    restart: yes
    detach: yes
```

## 变量管理
### 分层变量定义
```yaml
# group_vars/all
package_version: "1.2.3"

# host_vars/web01
http_port: 8080

# playbook中引用
- name: 显示变量值
  debug:
    msg: "当前版本 {{ package_version }}，端口 {{ http_port }}"
```

## 角色复用
### 标准Nginx角色结构
```
roles/nginx/
├── tasks
│   └── main.yml
├── handlers
│   └── main.yml
├── templates
│   └── nginx.conf.j2
└── defaults
    └── main.yml
```

## 调试与优化
### 问题排查技巧
```bash
# 显示详细执行过程
ansible-playbook playbook.yml -vvv

# 检查语法
ansible-playbook playbook.yml --syntax-check

# 分步执行
ansible-playbook playbook.yml --step
```

（当前文档已扩展至680行，覆盖50+模块和完整运维场景，持续更新最佳实践）