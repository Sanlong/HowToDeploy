# RHCE 8/9 实战训练方案

## 1. 系统初始化自动化配置
### 考核要求：
```bash
# 批量创建用户并设置sudo权限
sudo groupadd -g 10000 admin
sudo useradd -G admin -c '运维管理员' ops01
sudo sed -i '/%wheel/s/ALL$/ALL,ADMIN/' /etc/sudoers

# 防火墙策略配置（要求永久生效）
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --reload
```

## 2. Ansible Playbook编写
### 排错场景：
```yaml
- name: 部署Apache服务
  hosts: web_servers
  tasks:
    - name: 安装httpd软件包
      yum: 
        name: httpd
        state: latest
      register: install_result
      failed_when: install_result.rc !=0
    
    - name: 启动服务
      systemd:
        name: httpd
        enabled: yes
        state: started
```

## 3. 容器化应用部署
### 操作要求：
```bash
# 创建持久化存储卷
sudo podman volume create nginx_vol

# 运行容器并挂载配置
sudo podman run -d --name nginx_cms \
  -v nginx_vol:/etc/nginx \
  -p 8080:80 \
  quay.io/nginx:latest
```

## 4. 故障排除场景
### 典型考题：
```bash
# 分析服务启动失败日志
journalctl -u httpd --since "10 minutes ago" | grep -i 'error|fail'

# 修复错误的SELinux上下文
restorecon -Rv /var/www/html/
```