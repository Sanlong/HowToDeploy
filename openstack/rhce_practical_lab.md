# RHCE 9 实战训练实验室

## 模块一：系统初始化配置
### 考核目标：
1. 批量创建运维团队用户(ops01-ops05)
2. 配置sudo权限组
3. 防火墙服务管理
4. SELinux策略配置

```bash
# 用户与权限管理
sudo groupadd -g 1090 sysadmin
for i in {1..5}; do
  sudo useradd -G sysadmin -s /bin/bash -c "运维工程师" ops0$i
  echo "ops0$i:Cloud@123$" | sudo chpasswd
done

# 配置sudo权限
sudo bash -c 'cat > /etc/sudoers.d/10-sysadmin <<EOF
%sysadmin ALL=(ALL) /usr/bin/systemctl restart httpd, /usr/sbin/semanage
EOF'

# 防火墙永久放行服务
sudo firewall-cmd --permanent --add-service={http,https}
sudo firewall-cmd --reload

# SELinux布尔值配置
sudo setsebool -P httpd_can_network_connect_db on
```

## 模块二：Ansible自动化部署
### 场景要求：
1. 编写Playbook部署LAMP环境
2. 实现服务状态管理
3. 错误处理机制

```yaml
- name: 部署生产环境LAMP
  hosts: web_servers
  become: yes
  tasks:
    - name: 安装基础软件包
      yum:
        name:
          - httpd
          - mariadb-server
          - php
        state: present
      register: pkg_result
      failed_when: pkg_result.failed

    - name: 配置防火墙规则
      firewalld:
        service: "{{ item }}"
        permanent: yes
        state: enabled
      loop:
        - http
        - https
        - mysql

    - name: 确保服务开机启动
      systemd:
        name: "{{ item }}"
        enabled: yes
        state: started
      loop:
        - httpd
        - mariadb
```

## 模块三：容器化应用部署
### 操作要求：
1. 创建持久化存储卷
2. 配置容器网络映射
3. 实现自启动管理

```bash
# 创建应用程序存储卷
sudo podman volume create app_data

# 运行Nginx容器
sudo podman run -d \
  --name web_server \
  -v app_data:/var/www/html:Z \
  -p 8080:80 \
  --restart always \
  docker.io/library/nginx:alpine

# 验证端口映射
sudo podman port web_server
```

## 模块四：系统故障排除
### 典型场景：
1. 服务启动失败分析
2. 权限问题排查
3. 日志关键信息提取

## 模块五：高级系统配置
### 考核目标：
1. 磁盘配额配置与管理（10题）
2. 内核参数调优实践（15题）
3. 存储加密与解密（15题）
4. 系统性能基线设置（10题）

```bash
# 实战题1：配置用户组磁盘配额
sudo quotacheck -gum /shared
sudo setquota -g developers 500000 600000 0 0 /shared

# 实战题5：调整进程最大打开文件数
sudo sysctl -w fs.file-max=2097152
sudo bash -c 'echo "fs.file-max = 2097152" >> /etc/sysctl.conf'

# 实战题12：LUKS加密卷扩容
sudo cryptsetup resize secure_volume
sudo resize2fs /dev/mapper/secure_volume

# 实战题18：设置CPU性能模式
sudo tuned-adm profile throughput-performance
sudo cpupower frequency-set -g performance
```

## 模块六：Ansible高级场景
### 实践要求：
1. 角色开发与模块化设计（20题）
2. 敏感变量加密处理（15题）
3. 自定义过滤器开发（10题）
4. 动态库存配置（5题）

```yaml
# 实战题3：开发Nginx配置角色
- name: 部署nginx配置模板
  template:
    src: nginx.conf.j2
    dest: /etc/nginx/nginx.conf
    validate: nginx -t -c %s

# 实战题8：加密数据库凭据
ansible-vault encrypt_string --vault-password-file vault.pwd 'SuperSecret123!' >> vars.yml

# 实战题12：开发IP地址转换过滤器
def ip_to_hex(ip):
    return ''.join(['{:02x}'.format(int(octet)) for octet in ip.split('.')])

# 实战题19：AWS动态库存配置
plugin: aws_ec2
regions:
  - us-east-1
filters:
  tag:Environment: production
```

## 模块七：容器安全加固
### 实施要点：
1. 用户命名空间隔离（15题）
2. SELinux策略定制（20题）
3. 容器能力限制（10题）
4. 镜像签名验证（5题）

```bash
# 实战题4：配置容器UID映射范围
sudo podman run --uidmap 0:200000:5000 --name app1 -d nginx

# 实战题9：自定义容器文件上下文
sudo semanage fcontext -a -t container_file_t '/var/lib/containers(/.*)?'

# 实战题14：限制容器系统调用
sudo podman run --cap-drop=CAP_SYS_ADMIN --security-opt seccomp=/path/to/profile.json -d httpd

# 实战题18：验证镜像签名
sudo skopeo inspect --policy policy.json docker://registry.example.com/app:v1
```

## 模块八：复杂排错案例
### 诊断场景：
1. 系统启动引导修复（25题）
2. 资源限制问题分析（15题）
3. 内存泄漏追踪（7题）
4. 网络策略冲突排查（3题）

```bash
# 案例5：修复损坏的yum数据库
sudo rm -f /var/lib/rpm/__db*
sudo rpm --rebuilddb

# 案例12：诊断内存cgroup限制
cat /sys/fs/cgroup/memory/user.slice/memory.limit_in_bytes

# 案例19：追踪PHP内存泄漏
sudo valgrind --tool=memcheck --leak-check=full /usr/sbin/php-fpm

# 案例23：解决VLAN过滤冲突
sudo ethtool -K eth0 rx-vlan-filter off
sudo ip link set dev eth0 promisc on
```

## 模块六：Ansible高级场景
### 实践要求：
1. 角色开发与模块化设计
2. 敏感变量加密处理
3. 自定义过滤器开发
4. 动态库存配置

```yaml
# 创建加密变量文件
ansible-vault create secret_vars.yml

# 角色目录结构示例
roles/web_server/
├── tasks
│   ├── main.yml
│   └── configure_firewall.yml
├── handlers
│   └── restart_services.yml
└── templates
    └── httpd.conf.j2

# 动态库存脚本配置
#!/bin/bash
echo {"web": ["node1", "node2"]}
```

## 模块七：容器安全加固
### 实施要点：
1. 用户命名空间隔离
2. SELinux策略定制
3. 容器能力限制
4. 镜像签名验证

```bash
# 启用用户命名空间映射
sudo podman run --uidmap 0:100000:65536 -d nginx

# 自定义SELinux策略
sudo semanage module -a my_container_policy.pp

# 限制容器能力
sudo podman run --cap-drop=ALL --cap-add=NET_BIND_SERVICE -d httpd
```

## 模块八：复杂排错案例
### 诊断场景：
1. 系统启动引导修复
2. 资源限制问题分析
3. 内存泄漏追踪
4. 网络策略冲突排查

```bash
# 修复grub引导
sudo grub2-rebuild /boot/grub2/grub.cfg

# 分析进程资源限制
cat /proc/$(pgrep httpd)/limits

# 追踪内存泄漏工具
sudo valgrind --leak-check=full /usr/sbin/httpd
```

```bash
# 查看服务详细日志
journalctl -u mariadb --since "2024-02-01" --until "2024-02-28" \
  | grep -iE 'error|fail|denied'

# 修复文件上下文
sudo restorecon -Rv /var/www/html/

# 分析进程权限
ps auxZ | grep httpd
```