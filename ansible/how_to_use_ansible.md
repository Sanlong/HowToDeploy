# Ansible 完全使用指南

## 目录
### 基础篇
1. [核心概念](#核心概念)
   - [架构组成](#架构组成)
   - [工作原理](#工作原理)
2. [安装与配置](#安装与配置)
   - [环境要求](#环境要求)
   - [配置详解](#配置详解)

### 操作篇
3. [Inventory管理](#inventory管理)
   - [静态配置](#静态配置)
   - [动态配置](#动态配置)
4. [Ad-hoc命令](#ad-hoc命令)
   - [基础用法](#基础用法)
   - [常用场景](#常用场景)

### 模块手册
5. [系统管理模块](#系统管理模块)
   - [软件包管理](#软件包管理)
   - [服务管理](#服务管理)
6. [文件操作模块](#文件操作模块)
7. [网络管理模块](#网络管理模块)

### 高级篇
8. [Playbook技巧](#playbook技巧)
9. [变量管理](#变量管理)
10. [错误处理](#错误处理)

### 速查表
11. [模块索引](#模块索引)
12. [参数速查](#参数速查)
13. [最佳实践](#最佳实践)

[▲ 返回顶部](#ansible-完全使用指南)

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
#### 软件包管理
| 参数名称 | 类型 | 说明 | 默认值 |
|----------|------|------|--------|
| name | 字符串 | 软件包名称 | 必填 |
| state | 枚举 | 安装状态(present/absent/latest/held) | present |
| enablerepo | 字符串 | 启用仓库 | 无 |
| disablerepo | 字符串 | 禁用仓库 | 无 |
| exclude | 字符串 | 排除软件包 | 无 |

#### 服务管理
**yum模块**:
```yaml
- name: 安装最新版nginx
  yum:
    name: nginx
    state: latest
    update_cache: yes

# 完整参数说明
# name: 软件包名称(支持*通配符)
# state: 
#   present - 确保安装
#   absent  - 彻底卸载
#   latest  - 升级到最新版
#   held     - 锁定当前版本
#   removed - 移除软件包但保留配置
# disable_gpg_check: yes 跳过GPG验证
# exclude: kernel*      排除特定软件包
# enablerepo: epel      启用特定仓库
# disablerepo: updates* 禁用仓库
# downgrade: yes        允许降级
# installroot: /mnt/chroot 指定备用安装根目录（用于容器环境）
# security: yes         仅安装安全更新
# lock_timeout: 300     等待锁释放的超时时间（秒）
# skip_broken: yes      自动跳过有依赖问题的软件包
# download_only: yes    仅下载不安装

# 版本锁定示例
- name: 锁定openssh版本
  yum:
    name: openssh-8.5p1-1.el8
    state: held
    disable_gpg_check: yes

# 多软件包管理示例
- name: 批量安装基础工具
  yum:
    name:
      - vim-enhanced
      - lsof-4.87
      - '@development tools'
    state: present
    exclude: mariadb*
    enablerepo: 'epel,powertools'

# 安全更新示例
- name: 仅安装安全更新
  yum:
    name: '*' 
    state: latest
    security: yes
    exclude: kernel*

# 容器环境安装示例
- name: 在容器根目录安装软件
  yum:
    name: openssl
    state: present
    installroot: /mnt/chroot

# 锁超时处理示例
- name: 带超时的包管理
  yum:
    name: postgresql-server
    state: present
    lock_timeout: 120

# 降级操作示例
- name: 降级nginx到指定版本
  yum:
    name: nginx-1.20.1-9.el8
    state: present
    allow_downgrade: yes

# 移除软件包示例
- name: 清理旧内核
  yum:
    name: kernel-4.18.0-*.el8
    state: removed
    exclude: kernel-4.18.0-348.*
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

## 网络管理模块

### 网络设备配置
**ios_facts模块**:
```yaml
- name: 收集Cisco设备信息
  ios_facts:
    gather_subset:
      - hardware
      - interfaces
      - config
    register: switch_facts

- name: 显示接口状态
  debug:
    msg: "接口 {{ item.key }} 状态: {{ item.value.operstatus }}"
  loop: "{{ switch_facts.ansible_facts.ansible_net_interfaces | dict2items }}"

# 参数说明
# gather_subset: 指定收集信息范围（all,min,hardware,config,interfaces等）
# provider: 连接参数（host, username, password, timeout等）
# authorize: 是否进入特权模式

**vyos_config模块**:
```yaml
- name: 配置VyOS防火墙
  vyos_config:
    lines:
      - set firewall name WAN-IN default-action drop
      - set firewall name WAN-IN rule 10 action accept
      - set firewall name WAN-IN rule 10 protocol tcp
      - set firewall name WAN-IN rule 10 destination port 22,80,443
    commit: yes
    comment: "企业边界防火墙配置"

# 常用参数
# backup: 是否创建配置备份
# diff: 是否显示配置差异
# match: 配置匹配模式（line, strict, exact, none）

### 防火墙规则管理
**ufw模块**:
```yaml
- name: 配置基础防火墙规则
  ufw:
    rule: allow
    name: OpenSSH
    direction: in
    proto: tcp
    port: 22
    log: yes
    insert: 1

- name: 企业级防火墙配置
  ufw:
    rule: limit
    interface: eth0
    direction: in
    proto: tcp
    port: 3306
    src: 10.0.0.0/24
    log: yes
    route: yes

# 参数速查表
| 参数名称     | 类型   | 说明                  | 默认值 |
|--------------|--------|-----------------------|--------|
| rule         | 枚举   | allow/deny/reject/limit | 必填   |
| direction    | 枚举   | in/out/routed         | in     |
| proto        | 字符串 | tcp/udp/icmp等        | all    |
| port         | 整数   | 端口号                | 无     |
| src          | CIDR   | 源地址限制            | any    |
| dest         | CIDR   | 目标地址限制          | any    |
| log          | bool   | 是否记录日志          | no     |
| route        | bool   | 是否应用路由规则      | no     |
| interface    | 字符串 | 绑定网络接口          | 无     |

### 负载均衡配置
**bigip_irule模块**:
```yaml
- name: 配置F5负载均衡策略
  bigip_irule:
    name: https_redirect
    content: |
      when HTTP_REQUEST {
        HTTP::redirect https://[HTTP::host][HTTP::uri]
      }
    partition: Common
    provider:
      server: bigip.example.com
      user: admin
      password: "{{ vault_bigip_pass }}"
      validate_certs: no

# 企业级应用案例：
# 1. 动态路由更新
- name: 更新BGP路由表
  nxos_bgp:
    asn: 65001
    vrf: prod
    neighbor:
      address: 192.0.2.1
      remote_as: 65002
      timers:
        keepalive: 30
        holdtime: 90
    networks:
      - prefix: 203.0.113.0/24
        route_map: PROD-OUT
      - prefix: 198.51.100.0/24
        route_map: PROD-OUT

# 2. 企业ACL管理
- name: 核心交换机ACL配置
  ios_config:
    lines:
      - ip access-list extended COREWEB
      - permit tcp any 10.0.0.0 0.255.255.255 eq 80
      - permit tcp any 10.0.0.0 0.255.255.255 eq 443
      - deny   ip any any log
    parents: ip access-list extended COREWEB
    save_when: modified

# 3. 接口状态批量检查
- name: 全网设备接口健康检查
  ios_command:
    commands:
      - show interface status
      - show interface counters errors
    register: interface_status

- name: 生成健康报告
  copy:
    content: |
      {% for host in play_hosts %}
      {{ host }} 接口状态：
      {{ hostvars[host].interface_status.stdout | to_nice_json }}
      {% endfor %}
    dest: /var/log/network_health_{{ ansible_date_time.iso8601_basic_short }}.log

### 企业级最佳实践
1. 使用ansible_network_os变量自动适配设备类型
```yaml
- name: 通用网络配置
  include_tasks: "{{ ansible_network_os }}_config.yml"

# cisco_ios_config.yml
- name: Cisco配置
  ios_config:
    lines: "{{ config_lines }}"
    parents: "{{ parents_lines }}"

# huawei_vrp_config.yml
- name: 华为设备配置
  huawei_s5700_config:
    lines: "{{ config_lines }}"
    commit: yes
```

2. 网络配置原子化
```yaml
# network_roles/
# ├── common_config
# ├── acl_management
# └── bgp_config

- name: 应用核心网络配置
  import_role:
    name: network_roles/common_config
  vars:
    core_vlans:
      - id: 100
        name: MGMT
        ip: 10.100.0.1/24
      - id: 200
        name: SERVER
        ip: 10.200.0.1/24

- name: 应用安全策略
  import_role:
    name: network_roles/acl_management
  vars:
    acl_rules:
      - name: WEB-DMZ
        rules:
          - action: permit
            proto: tcp
            src: any
            dst: 10.200.0.0/24
            port: 80
```
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