# RHCE 9 详细考试大纲

## 课程概述

### 课程目标
- 掌握Red Hat Enterprise Linux 9的核心管理技能
- 熟练运用系统管理、网络配置、存储管理等技术
- 能够独立解决企业级Linux运维问题
- 具备RHCE认证考试所需的全部知识和技能

### 适用人群
- Linux系统管理员
- 运维工程师
- DevOps工程师
- 准备RHCE认证的IT从业人员

### 课程模块
<!-- TOC -->
## 目录导航
- [模块一：基础系统管理](#模块一基础系统管理)
  - [用户与权限管理](#用户与权限管理)
  - [文件系统管理](#文件系统管理)
  - [服务管理](#服务管理)
- [模块二：网络配置与管理](#模块二网络配置与管理)
  - [防火墙配置](#防火墙配置)
  - [接口配置](#接口配置)
- [模块三：存储管理](#模块三存储管理)
  - [磁盘管理](#磁盘管理)
  - [逻辑卷管理](#逻辑卷管理)
  - [VDO存储优化](#vdo存储优化)
<!-- /TOC -->

## 模块一：基础系统管理

### 学习目标
- 掌握Linux文件系统结构和管理方法
- 熟练运用用户和权限管理命令
- 掌握系统服务配置与管理
- 能够进行基础的系统故障诊断

### 知识要点
1. 文件系统基础
2. 用户与权限管理
3. 服务管理与配置
4. 系统监控与故障排查

### 文件系统基础

#### 系统目录结构解析

##### 主要目录说明
- `/bin`：基本命令目录
- `/sbin`：系统管理命令目录
- `/etc`：配置文件目录
- `/home`：用户主目录
- `/root`：root用户主目录
- `/var`：可变数据目录
- `/tmp`：临时文件目录
- `/usr`：应用程序目录
- `/opt`：第三方软件目录
- `/proc`：进程和内核信息虚拟文件系统
- `/sys`：设备和驱动信息虚拟文件系统

##### 重要配置文件
- `/etc/fstab`：文件系统挂载配置
- `/etc/passwd`：用户账户信息
- `/etc/shadow`：用户密码信息
- `/etc/group`：用户组信息
- `/etc/sudoers`：sudo权限配置

#### 文件系统操作

##### 基本操作命令
```bash
# 查看文件系统使用情况
df -h

# 查看目录大小
du -sh /path/to/directory

# 查找大文件
find / -type f -size +100M

# 检查文件系统
fsck /dev/sda1

# 挂载文件系统
mount /dev/sda1 /mnt/disk
```

##### 文件系统管理最佳实践
1. 定期检查文件系统使用情况
   ```bash
   # 创建磁盘使用报告
   df -h > disk_usage_report.txt
   ```

2. 合理规划分区大小
   - 根分区（/）：建议50GB以上
   - /home分区：根据用户数量和需求配置
   - /var分区：建议20GB以上，用于日志和缓存

3. 定期清理临时文件
   ```bash
   # 清理/tmp目录
   find /tmp -type f -atime +10 -delete
   ```

4. 配置自动挂载
   ```bash
   # /etc/fstab示例
   /dev/sda1  /data  ext4  defaults  0  2
   ```

#### 故障排查指南
1. 文件系统只读问题
   ```bash
   # 检查文件系统状态
   mount | grep "ro,"
   
   # 尝试重新挂载为读写
   mount -o remount,rw /
   ```

2. 磁盘空间不足
   ```bash
   # 查找大文件
   find / -type f -size +100M -exec ls -lh {} \;
   
   # 清理日志文件
   journalctl --vacuum-time=2d
   ```

3. inode耗尽问题
   ```bash
   # 检查inode使用情况
   df -i
   
   # 查找包含大量小文件的目录
   find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n
   ```

#### 性能优化建议
1. 使用适当的文件系统类型
   - XFS：适合大文件和高性能要求
   - Ext4：通用性好，稳定可靠

2. 合理配置挂载选项
   ```bash
   # 性能优化挂载选项示例
   /dev/sda1  /data  xfs  noatime,nodiratime  0  2
   ```

3. 定期进行碎片整理
   ```bash
   # XFS碎片整理
   xfs_fsr /dev/sda1
   ```

4. 配置日志轮转
   ```bash
   # 编辑logrotate配置
   vim /etc/logrotate.d/custom
   ```

### 用户与权限管理

#### 用户管理基础

##### 用户相关命令
```bash
# 创建新用户
useradd -m -s /bin/bash username

# 设置用户密码
passwd username

# 修改用户属性
usermod -aG wheel username  # 添加到wheel组
usermod -s /bin/bash username  # 修改shell

# 删除用户
userdel -r username  # -r选项同时删除用户主目录
```

##### 用户配置文件
- `/etc/passwd`：用户账户信息
- `/etc/shadow`：用户密码信息
- `/etc/group`：组信息
- `/etc/login.defs`：用户创建默认配置
- `/etc/skel/`：用户主目录模板

#### 权限管理

##### 基本权限
```bash
# 修改文件权限
chmod 755 file  # 数字表示法
chmod u+x file  # 符号表示法

# 修改所有者
chown user:group file

# 修改所属组
chgrp group file

# 递归修改权限
chmod -R 755 directory
chown -R user:group directory
```

##### 特殊权限
1. SUID (Set User ID)
   ```bash
   # 设置SUID权限
   chmod u+s file
   chmod 4755 file
   ```

2. SGID (Set Group ID)
   ```bash
   # 设置SGID权限
   chmod g+s directory
   chmod 2755 directory
   ```

3. Sticky Bit
   ```bash
   # 设置Sticky Bit
   chmod +t directory
   chmod 1777 directory
   ```

##### ACL权限管理
```bash
# 查看ACL权限
getfacl file

# 设置ACL权限
setfacl -m u:user:rwx file  # 为用户设置权限
setfacl -m g:group:rx file  # 为组设置权限

# 递归设置ACL
setfacl -R -m u:user:rwx directory

# 删除ACL权限
setfacl -x u:user file
```

#### 权限管理最佳实践

1. 最小权限原则
   - 仅授予必要的权限
   - 定期审查权限设置
   - 及时撤销不需要的权限

2. 用户组管理
   ```bash
   # 创建项目组
   groupadd project_team
   
   # 添加用户到组
   usermod -aG project_team user1
   
   # 设置目录组权限
   chown :project_team /project
   chmod g+rwx /project
   ```

3. 安全配置
   ```bash
   # 设置安全的umask
   echo "umask 027" >> /etc/profile
   
   # 限制su命令使用
   echo "auth required pam_wheel.so" >> /etc/pam.d/su
   ```

4. 定期权限审计
   ```bash
   # 查找SUID文件
   find / -perm -4000 -type f
   
   # 查找世界可写文件
   find / -perm -2 -type f
   ```

#### 故障排查指南

1. 权限拒绝问题
   ```bash
   # 检查文件权限
   ls -l file
   
   # 检查父目录权限
   namei -l /path/to/file
   
   # 检查SELinux上下文
   ls -Z file
   ```

2. 用户无法登录
   ```bash
   # 检查账户状态
   passwd -S username
   
   # 检查shell设置
   grep username /etc/passwd
   
   # 检查PAM配置
   cat /etc/pam.d/sshd
   ```

3. sudo权限问题
   ```bash
   # 检查sudo配置
   visudo
   
   # 检查用户组成员关系
   groups username
   
   # 查看sudo日志
   tail /var/log/secure
   ```

#### 安全加固建议

1. 密码策略
   ```bash
   # 编辑密码策略
   vim /etc/security/pwquality.conf
   
   # 设置密码过期
   chage -M 90 username
   ```

2. 访问控制
   ```bash
   # 限制root SSH登录
   vim /etc/ssh/sshd_config
   PermitRootLogin no
   
   # 配置sudo访问
   visudo
   ```

3. 审计跟踪
   ```bash
   # 启用审计服务
   systemctl enable auditd
   
   # 配置审计规则
   auditctl -w /etc/passwd -p wa -k passwd_changes
   ```

### 服务管理

#### Systemd服务基础

##### 基本概念
- Unit：systemd管理的基本单位
- Target：一组Unit的集合
- Service：服务单元
- Socket：套接字单元
- Timer：定时器单元

##### 常用命令
```bash
# 查看系统服务状态
systemctl status service_name

# 启动服务
systemctl start service_name

# 停止服务
systemctl stop service_name

# 重启服务
systemctl restart service_name

# 重新加载配置
systemctl reload service_name

# 设置开机自启
systemctl enable service_name

# 禁用开机自启
systemctl disable service_name

# 查看服务是否开机自启
systemctl is-enabled service_name
```

#### 服务配置管理

##### 服务单元文件
```ini
# /etc/systemd/system/custom.service
[Unit]
Description=Custom Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/custom-script
Restart=always
User=custom-user

[Install]
WantedBy=multi-user.target
```

##### 配置修改流程
```bash
# 编辑服务配置
systemctl edit service_name

# 重新加载systemd配置
systemctl daemon-reload

# 重启服务使配置生效
systemctl restart service_name
```

#### 服务监控与日志

##### 日志查看
```bash
# 查看服务日志
journalctl -u service_name

# 查看启动以来的日志
journalctl -u service_name --boot

# 查看最近的日志
journalctl -u service_name -n 100

# 实时查看日志
journalctl -u service_name -f
```

##### 服务状态监控
```bash
# 查看所有服务状态
systemctl list-units --type=service

# 查看失败的服务
systemctl --failed

# 查看服务依赖关系
systemctl list-dependencies service_name
```

#### 服务管理最佳实践

1. 服务命名规范
   ```bash
   # 自定义服务命名
   custom-app@instance.service
   ```

2. 依赖管理
   ```ini
   [Unit]
   Description=Custom Application
   After=network.target postgresql.service
   Requires=postgresql.service
   ```

3. 资源限制
   ```ini
   [Service]
   CPUQuota=50%
   MemoryLimit=1G
   LimitNOFILE=65535
   ```

4. 自动重启策略
   ```ini
   [Service]
   Restart=on-failure
   RestartSec=5s
   StartLimitInterval=500s
   StartLimitBurst=5
   ```

#### 故障排查指南

1. 服务启动失败
   ```bash
   # 查看详细状态
   systemctl status service_name -l
   
   # 查看启动日志
   journalctl -u service_name -b
   
   # 检查配置文件语法
   systemd-analyze verify service_name.service
   ```

2. 服务异常退出
   ```bash
   # 查看服务退出状态
   systemctl status service_name
   
   # 检查系统资源使用
   top
   free -h
   df -h
   ```

3. 依赖问题
   ```bash
   # 检查依赖关系
   systemctl list-dependencies service_name
   
   # 验证依赖服务状态
   systemctl status dependent_service
   ```

#### 性能优化建议

1. 服务启动优化
   ```bash
   # 分析启动时间
   systemd-analyze blame
   
   # 并行启动服务
   systemctl set-property service_name.service DefaultDependencies=no
   ```

2. 资源使用优化
   ```ini
   [Service]
   # 限制CPU使用
   CPUQuota=50%
   
   # 限制内存使用
   MemoryLimit=1G
   
   # 限制IO带宽
   IOWeight=500
   ```

3. 日志管理
   ```bash
   # 配置日志轮转
   journalctl --vacuum-size=1G
   
   # 限制日志大小
   journalctl --vacuum-time=1week
   ```

4. 监控告警设置
   ```bash
   # 创建服务监控脚本
   vim /usr/local/bin/service-monitor.sh
   
   # 设置监控定时任务
   systemctl edit service-monitor.timer
   ```

## 模块二：网络配置与管理

### 学习目标
- 掌握Linux网络配置和管理方法
- 熟练运用防火墙配置命令
- 掌握网络接口配置技巧
- 能够进行网络故障诊断和排查

### 知识要点
1. 防火墙配置与管理
2. 网络接口配置
3. 网络服务管理
4. 网络故障排查

### 防火墙配置

#### firewalld基础

##### 基本概念
- Zone：网络区域
- Service：预定义的服务
- Port：端口
- Rich Rule：富规则
- Direct Rule：直接规则

##### 常用命令
```bash
# 查看防火墙状态
firewall-cmd --state

# 查看区域信息
firewall-cmd --list-all-zones

# 查看当前活动区域
firewall-cmd --get-active-zones

# 查看默认区域
firewall-cmd --get-default-zone

# 设置默认区域
firewall-cmd --set-default-zone=public
```

#### 规则管理

##### 服务管理
```bash
# 查看所有可用服务
firewall-cmd --get-services

# 添加服务到区域
firewall-cmd --zone=public --add-service=http --permanent

# 移除服务
firewall-cmd --zone=public --remove-service=http --permanent

# 重新加载配置
firewall-cmd --reload
```

##### 端口管理
```bash
# 开放端口
firewall-cmd --zone=public --add-port=80/tcp --permanent

# 关闭端口
firewall-cmd --zone=public --remove-port=80/tcp --permanent

# 查看开放的端口
firewall-cmd --zone=public --list-ports
```

##### 富规则管理
```bash
# 添加富规则
firewall-cmd --add-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept' --permanent

# 移除富规则
firewall-cmd --remove-rich-rule='rule family="ipv4" source address="192.168.1.0/24" service name="ssh" accept' --permanent

# 查看富规则
firewall-cmd --list-rich-rules
```

### 网络接口配置

#### NetworkManager基础

##### 常用命令
```bash
# 查看所有连接
nmcli connection show

# 查看设备状态
nmcli device status

# 查看特定连接详情
nmcli connection show "连接名称"

# 启用/禁用连接
nmcli connection up "连接名称"
nmcli connection down "连接名称"
```

##### 配置网络接口
```bash
# 创建新的以太网连接
nmcli connection add type ethernet con-name "eth0" ifname eth0

# 配置IP地址
nmcli connection modify "eth0" ipv4.addresses "192.168.1.100/24"

# 配置网关
nmcli connection modify "eth0" ipv4.gateway "192.168.1.1"

# 配置DNS
nmcli connection modify "eth0" ipv4.dns "8.8.8.8"

# 设置自动获取IP
nmcli connection modify "eth0" ipv4.method auto
```

#### 网络配置文件
```bash
# 网络接口配置文件位置
/etc/sysconfig/network-scripts/ifcfg-*

# DNS配置文件
/etc/resolv.conf

# 主机名配置
/etc/hostname
```

#### 网络管理最佳实践

1. 网络安全配置
   ```bash
   # 禁用不需要的网络服务
   systemctl disable telnet.socket
   
   # 配置SSH安全选项
   vim /etc/ssh/sshd_config
   PermitRootLogin no
   PasswordAuthentication no
   ```

2. 防火墙策略
   ```bash
   # 默认拒绝所有入站连接
   firewall-cmd --set-default-zone=drop
   
   # 仅允许必要的服务
   firewall-cmd --zone=public --add-service={ssh,http,https} --permanent
   ```

3. 网络监控
   ```bash
   # 安装网络监控工具
   dnf install iptraf-ng nethogs
   
   # 配置网络流量监控
   iptraf-ng
   ```

#### 故障排查指南

1. 连接问题
   ```bash
   # 检查网络接口状态
   ip link show
   
   # 测试网络连通性
   ping gateway_ip
   
   # 检查路由表
   ip route show
   ```

2. DNS问题
   ```bash
   # 测试DNS解析
   nslookup domain.com
   
   # 检查DNS配置
   cat /etc/resolv.conf
   
   # 使用不同DNS服务器测试
   dig @8.8.8.8 domain.com
   ```

3. 防火墙问题
   ```bash
   # 检查防火墙规则
   firewall-cmd --list-all
   
   # 临时禁用防火墙测试
   systemctl stop firewalld
   
   # 查看防火墙日志
   journalctl -u firewalld
   ```

#### 性能优化建议

1. 网络参数优化
   ```bash
   # 编辑系统网络参数
   vim /etc/sysctl.conf
   
   # 常用优化参数
   net.ipv4.tcp_fin_timeout = 30
   net.ipv4.tcp_keepalive_time = 1200
   net.core.rmem_max = 16777216
   ```

2. 网络服务优化
   ```bash
   # 优化SSH服务
   vim /etc/ssh/sshd_config
   UseDNS no
   GSSAPIAuthentication no
   ```

3. 带宽管理
   ```bash
   # 安装流量控制工具
   dnf install tc
   
   # 配置带宽限制
   tc qdisc add dev eth0 root tbf rate 1mbit burst 32kbit latency 400ms
   ```

## 模块三：存储管理

### 学习目标
- 掌握Linux存储管理基础知识
- 熟练运用LVM管理命令
- 掌握VDO存储优化技术
- 能够进行存储故障诊断和处理

### 知识要点
1. 磁盘分区与管理
2. LVM逻辑卷管理
3. VDO存储优化
4. 存储性能优化

### 磁盘管理

#### 基础概念
- 物理设备：如/dev/sda、/dev/nvme0n1
- 分区：如/dev/sda1、/dev/sda2
- 文件系统：ext4、xfs、btrfs等
- 挂载点：文件系统在目录树中的位置

#### 分区管理

##### 查看磁盘信息
```bash
# 查看磁盘分区
lsblk

# 查看磁盘详细信息
fdisk -l

# 查看文件系统使用情况
df -h
```

##### 创建和管理分区
```bash
# 使用fdisk创建分区
fdisk /dev/sdb

# 使用gdisk创建GPT分区
gdisk /dev/sdb

# 格式化分区
mkfs.xfs /dev/sdb1
mkfs.ext4 /dev/sdb2

# 挂载分区
mount /dev/sdb1 /mnt/data
```

### 逻辑卷管理

#### LVM基础

##### 基本概念
- 物理卷（PV）：物理存储设备
- 卷组（VG）：PV的集合
- 逻辑卷（LV）：从VG中分配的存储空间

##### 创建LVM
```bash
# 创建物理卷
pvcreate /dev/sdb1 /dev/sdc1

# 创建卷组
vgcreate vg_data /dev/sdb1 /dev/sdc1

# 创建逻辑卷
lvcreate -L 10G -n lv_data vg_data
```

#### LVM管理操作

##### 扩展逻辑卷
```bash
# 扩展逻辑卷
lvextend -L +5G /dev/vg_data/lv_data

# 扩展文件系统
xfs_growfs /dev/vg_data/lv_data  # XFS文件系统
resize2fs /dev/vg_data/lv_data   # EXT4文件系统
```

##### 快照管理
```bash
# 创建快照
lvcreate -s -L 5G -n snap_data /dev/vg_data/lv_data

# 恢复快照
lvconvert --merge /dev/vg_data/snap_data
```

### VDO存储优化

#### VDO基础

##### 概念介绍
- 重复数据删除
- 压缩
- 精简配置

##### 配置VDO
```bash
# 创建VDO卷
vdo create --name=vdo1 --device=/dev/sdb --vdoLogicalSize=100G

# 格式化VDO卷
mkfs.xfs /dev/mapper/vdo1

# 挂载VDO卷
mount /dev/mapper/vdo1 /mnt/vdo
```

#### VDO管理

##### 监控和维护
```bash
# 查看VDO状态
vdo status

# 查看统计信息
vdostats --human-readable

# 启动/停止VDO
vdo start --name=vdo1
vdo stop --name=vdo1
```

### 存储管理最佳实践

1. 分区规划
   ```bash
   # 推荐的分区方案
   /boot     - 1GB
   swap      - 2x RAM (最大8GB)
   /         - 50GB
   /home     - 剩余空间
   ```

2. LVM配置
   ```bash
   # 预留空间供将来扩展
   vgcreate vg_data /dev/sdb1 /dev/sdc1 -s 16M
   
   # 使用逻辑卷快照进行备份
   lvcreate -s -L 5G -n backup_snap /dev/vg_data/lv_data
   ```

3. 性能优化
   ```bash
   # 调整IO调度器
   echo deadline > /sys/block/sda/queue/scheduler
   
   # 优化文件系统挂载选项
   mount -o noatime,nodiratime /dev/sda1 /mnt/data
   ```

### 故障排查指南

1. 磁盘故障
   ```bash
   # 检查磁盘健康状态
   smartctl -a /dev/sda
   
   # 检查文件系统错误
   fsck /dev/sda1
   
   # 检查坏块
   badblocks -v /dev/sda1
   ```

2. LVM问题
   ```bash
   # 检查PV状态
   pvs -a
   
   # 检查VG状态
   vgs -v
   
   # 检查LV状态
   lvs -a -o +devices
   ```

3. 性能问题
   ```bash
   # 监控IO性能
   iostat -xz 1
   
   # 查看当前IO操作
   iotop
   
   # 检查文件系统使用情况
   df -i  # 检查inode使用情况
   ```

### 性能优化建议

1. 文件系统选择
   - XFS：适合大文件，支持在线扩展
   - Ext4：通用性好，支持日志功能
   - Btrfs：支持快照和数据校验

2. RAID配置
   ```bash
   # 创建RAID 10阵列
   mdadm --create /dev/md0 --level=10 --raid-devices=4 /dev/sd[b-e]1
   
   # 监控RAID状态
   mdadm --detail /dev/md0
   ```

3. IO调优
   ```bash
   # 设置预读大小
   blockdev --setra 16384 /dev/sda
   
   # 调整swappiness
   sysctl vm.swappiness=10
   ```

4. 备份策略
   ```bash
   # 使用LVM快照
   lvcreate -s -L 5G -n backup_snap /dev/vg_data/lv_data
   
   # 配置定时备份
   0 2 * * * /usr/local/bin/backup-script.sh
   ```

## 考试准备指南

### 重点复习内容

#### 1. 系统管理核心技能
- 用户和权限管理
- 服务配置和管理
- 文件系统操作
- 系统监控和故障排查

#### 2. 网络配置要点
- 防火墙规则配置
- 网络接口管理
- DNS和路由配置
- 网络故障诊断

#### 3. 存储管理重点
- LVM的创建和管理
- 文件系统配置
- 存储性能优化
- 备份和恢复策略

### 实践建议

#### 1. 环境搭建
- 使用虚拟机搭建练习环境
- 模拟真实的企业网络架构
- 练习常见故障的排查和解决
- 熟悉考试环境的基本设置

#### 2. 练习方法
```bash
# 创建测试环境
# 1. 安装两台RHEL 9虚拟机
# 2. 配置网络连接
# 3. 规划存储结构
```

#### 3. 时间管理
- 考试时间：4小时
- 建议时间分配：
  * 阅读题目：20分钟
  * 系统配置：2小时
  * 网络配置：1小时
  * 检查和优化：40分钟

### 常见问题解答

#### 1. 考试环境
Q: 考试环境是否提供互联网访问？
A: 不提供。考试环境是封闭的，需要依靠本地文档和帮助系统。

Q: 是否可以使用自己的笔记？
A: 不可以。考试时只能使用系统提供的文档。

#### 2. 考试内容
Q: 考试是否包含图形界面操作？
A: 不包含。RHCE考试主要测试命令行操作能力。

Q: 如何处理考试中遇到的问题？
A: 
- 仔细阅读错误信息
- 查看系统日志
- 使用man和help命令
- 按照故障排查流程处理

#### 3. 评分标准
Q: 如何计算考试成绩？
A: 根据任务完成情况评分，需要达到总分的70%才能通过。

Q: 是否所有题目分值相同？
A: 不同任务的分值不同，建议先完成高分值的任务。

### 考试技巧

#### 1. 时间管理
- 先通读所有题目
- 规划任务执行顺序
- 预留检查时间
- 合理分配各题时间

#### 2. 答题策略
```bash
# 1. 备份配置文件
cp /etc/sysconfig/network-scripts/ifcfg-eth0{,.bak}

# 2. 记录重要命令
history >> /root/command_log.txt

# 3. 定期检查任务完成情况
```

#### 3. 注意事项
- 仔细阅读每道题的要求
- 注意配置的持久化
- 及时验证配置效果
- 做好配置文件备份

### 复习计划建议

#### 第一阶段：基础知识（2周）
- 复习基本命令
- 练习文件系统操作
- 熟悉服务管理
- 掌握用户管理

#### 第二阶段：进阶技能（2周）
- 深入学习网络配置
- 练习存储管理
- 掌握安全设置
- 系统优化技巧

#### 第三阶段：模拟练习（1周）
- 完整模拟考试
- 计时练习
- 总结经验
- 查漏补缺

### 考试当天建议

#### 1. 考前准备
- 保证充足睡眠
- 提前到达考场
- 熟悉考试环境
- 调整心态

#### 2. 考试中
- 仔细阅读题目
- 按计划执行
- 及时检查结果
- 合理分配时间

#### 3. 考试后
- 记录经验教训
- 总结不足之处
- 持续学习提高
- 规划后续发展

### 常用Linux命令总结
1. 文件操作命令
   ```bash
   # 目录操作
   ls -alh  # 查看详细文件信息
   mkdir -p /data/{app,log}  # 递归创建目录
   rsync -avzP src/ user@host:/dest/  # 增量同步

   # 文件操作
   find /var/log -name "*.log" -mtime +7  # 查找过期日志

   # 参数详解：
   # -name 使用通配符匹配.log结尾文件（*匹配任意字符，?匹配单个字符）
   # -mtime +7 表示修改时间超过7天（+n: >n天，-n: <n天，n: [n-1,n)天）
   # 时间单位换算：1天=1440分钟，1周=10080分钟
   # -exec 参数组合操作示例：
   # find /var/log -name "*.log" -mtime +30 -exec rm -fv {} \;
   # 典型应用场景：
   # 1. 定期日志清理  2. 故障排查  3. 合规审计
   grep -rin "error" /var/log/messages  # 递归搜索错误信息
   tail -f /var/log/secure  # 实时查看认证日志
   ```

2. 权限管理命令
   ```bash
   # 权限配置
   chmod 2750 /shared  # 设置SGID目录
   setfacl -m u:user1:rwx,g:dev:r-x file.txt  # ACL权限控制
   restorecon -Rv /etc/nginx  # 修复SELinux上下文

   # 用户管理
   passwd -S user1  # 查看账户状态
   chage -M 90 -W 14 user1  # 设置密码策略
   ```

3. 系统监控命令
   ```bash
   # 性能分析
   # top实时监控技巧
   top -b -n 5 -d 2 > top_report.txt  # 批处理模式(每2秒采集1次，共5次)
   top -H -p $(pgrep nginx)  # 监控特定进程的线程
   
   # vmstat高级用法
   vmstat 1 10  # 每秒采集1次，共10次
   vmstat -s -S M  # 以MB为单位显示内存统计
   
   # 参数详解：
   # 第一个数字1表示采样间隔（秒）
   # 第二个数字10表示采样次数
   # -s 显示内存事件统计
   # -S M 指定单位为MB（K=KB, M=MB, G=GB）
   # 总监控时长 = 间隔 × 次数 = 1×10=10秒
   
   # iostat深度分析
   iostat -xz 1  # 查看设备利用率与饱和度
   iostat -d sda -p 2 3  # 监控特定磁盘分区
   
   # sar历史数据分析
   sar -u -f /var/log/sa/sa$(date +%d -d yesterday)  # 查看昨日CPU历史
   sar -r -s 10:00:00 -e 12:00:00  # 指定时间范围内存分析
   
   # 性能基线设置方法
   # 采集典型工作负载数据(持续24小时)
   sar -A -o /var/log/sa/perfbaseline 60 1440
   
   # 四维监控策略
   # CPU监控项：usr%, sys%, idle%, steal%
   # 内存监控项：free, buff, cache, si/so
   # 磁盘IO监控项：await, %util, r/s, w/s 
   # 网络监控项：rxkB/s, txkB/s, drop/s
   
   # 自动化监控脚本示例
   #!/bin/bash
   LOG_DIR=/var/log/perfmon
   mkdir -p $LOG_DIR
   
   # 采集系统性能快照
   timestamp=$(date +%Y%m%d_%H%M%S)
   top -b -n1 -c > ${LOG_DIR}/top_${timestamp}.log
   vmstat 1 10 > ${LOG_DIR}/vmstat_${timestamp}.log
   iostat -xz 1 5 > ${LOG_DIR}/iostat_${timestamp}.log
   
   # 性能瓶颈分析逻辑
   analyze_cpu() {
     awk '/%Cpu/ {if(($2 + $4) > 80) print "CPU高负载告警"}' ${LOG_DIR}/top_*.log
   }
   
   analyze_memory() {
     awk '/MiB Mem/ {if($8/$2*100 > 90) print "内存使用超阈值"}' ${LOG_DIR}/top_*.log
   }
   
   # 生成日报
   echo "### 性能日报 $(date) ###" > ${LOG_DIR}/daily_report.txt
   sar -u | tail -n +3 >> ${LOG_DIR}/daily_report.txt
   sar -r | tail -n +3 >> ${LOG_DIR}/daily_report.txt
   
   # 定时任务配置示例
   echo "*/5 * * * * root /usr/local/bin/perf_monitor.sh" > /etc/cron.d/perfmon
   
   # 典型瓶颈分析案例
   # 1. CPU瓶颈：%us高→应用优化；%sy高→内核调优
   # 2. 内存瓶颈：si/so持续>0→添加物理内存
   # 3. 磁盘瓶颈：await>ms级别→检查RAID/SSD
   # 4. 网络瓶颈：drop>0→检查带宽/网卡配置
   
   # 长期监控建议
   # 1. 使用Prometheus+Grafana建立可视化监控
   # 2. 配置异常阈值告警
   # 3. 定期执行性能基准测试
   # 4. 保留至少30天历史数据

   # 进程管理
   pstree -p  # 显示进程树
   lsof -i :80  # 查看端口占用
   ```

4. 网络配置命令
   ```bash
   nmcli con mod eth0 ipv4.addresses 192.168.1.100/24  # 配置静态IP
   ss -tulnp  # 查看监听端口
   traceroute --tcp -p 80 example.com  # TCP协议路由追踪
   ```

5. 存储管理命令
   ```bash
   lsblk -o NAME,SIZE,FSTYPE,MOUNTPOINT  # 块设备信息
   blkid /dev/sda1  # 查看分区UUID
   resize2fs /dev/vg01/lv_data  # 在线扩展文件系统
   ```

6. 软件管理命令
   ```bash
   yum history undo 15  # 回滚特定事务
   rpm -Va --nofiledigest  # 验证软件包完整性
   dnf module list postgresql  # 查看模块流
   ```

7. 日志分析命令
   ```bash
   journalctl --since "30 min ago" -u nginx  # 时间范围过滤
   ausearch -ts recent -k user_login  # 审计日志查询
   logwatch --detail high  # 生成日志摘要
   ```

8. 系统维护命令
   ```bash
   timedatectl set-ntp true  # 启用NTP同步
   grub2-mkconfig -o /boot/grub2/grub.cfg  # 重建引导配置
   sosreport --batch --ticket-number T12345  # 收集诊断信息
   ```

### 文件系统基础
### 系统目录结构解析
### 系统目录结构解析
#### Linux目录标准（FHS）
1. **核心目录功能**
   - 学习目标：
     * 掌握Filesystem Hierarchy Standard规范
     * 理解系统/用户目录划分原则

   - 操作示例：
     ```bash
     # 查看目录树结构
     tree -L 1 /
     
     # 统计目录大小
     du -sh /var/log/

     # /boot - 系统启动目录
   - 功能说明：内核文件、引导加载程序配置
   - 典型操作：
     * 查看grub配置：ls /boot/grub2
     * 检查内核版本：uname -r

     # /etc - 配置目录
   - 功能说明：系统全局配置文件存储
   - 典型操作：
     * 备份配置：tar czf etc_backup.tar.gz /etc
     * 查看SSH配置：vim /etc/ssh/sshd_config

     # 日志轮转配置示例
     vim /etc/logrotate.d/syslog
     ```

### 系统安装部署
   - 学习内容：
     * 了解Red Hat Enterprise Linux 9的安装要求
     * 掌握安装介质准备和启动方法
     * 学习安装过程中的分区方案选择
     * 掌握系统初始化配置
   - 操作示例：
     ```bash
     # 创建安装介质
     dd if=rhel9.iso of=/dev/sdb bs=4M status=progress
     
     # 启动安装程序
     # 在BIOS中选择USB启动
     
     # 分区方案示例
     /boot 1G
     swap 4G
     / 20G
     /home 剩余空间
     
     # 初始化配置
     hostnamectl set-hostname rhel9-server
     timedatectl set-timezone Asia/Shanghai
     ```
3. 用户与权限管理
   - 学习内容：
     * 用户与组的基本概念
     * 用户生命周期管理（创建/修改/删除）
     * 密码策略配置（复杂度、过期时间、历史记录）
     * sudo权限配置与继承机制
     * 组权限管理（主组/附加组）
     * 用户环境变量配置
   
   - 详细知识点：
     1. 用户管理
       ```bash
       # 创建系统用户
       useradd -r -s /sbin/nologin sysuser  # -r: 创建系统用户；-s: 指定登录shell；/sbin/nologin禁止交互登录
       
       # 修改用户属性
       usermod -d /newhome -s /bin/bash testuser  # -d: 修改主目录；-s: 更改登录shell
       
       # 删除用户并清理主目录
       userdel -r obsoleteuser  # -r: 删除用户同时移除主目录和邮件池
       ```

     2. 密码策略配置（/etc/login.defs）
       ```bash
       # 密码最长有效期（天）
       PASS_MAX_DAYS 90
       # 密码最短有效期
       PASS_MIN_DAYS 7
       # 密码最小长度
       PASS_MIN_LEN 10
       # 密码过期前警告天数
       PASS_WARN_AGE 14
       # 保留最近5个历史密码
       ENCRYPT_METHOD SHA512
       ```

     3. sudo权限继承机制
       ```bash
       # 权限继承示例
       %admin ALL=(ALL:ALL) ALL  # 管理员组完全权限
       %devteam ALL=(operator) /usr/bin/systemctl restart httpd
       
       # 带环境变量的权限
       Defaults env_keep += "http_proxy"
       
       # 时间限制权限
       User_Alias TEMPUSER = user1,user2
       TEMPUSER ALL=(ALL) NOPASSWD: ALL, !/usr/bin/passwd root
       ```

     4. 组权限管理
       ```bash
       # 主组与附加组
       groupadd -g 10000 devgroup
       usermod -g devgroup user1
       usermod -aG wheel,backup user1
       
       # 组权限继承
       setfacl -d -m g:devgroup:rwx /project
       
       # 共享目录配置
       mkdir /shared
       chgrp devgroup /shared
       chmod 2775 /shared
       ```

     5. 用户环境配置
       ```bash
       # 全局配置 /etc/profile
       export HISTSIZE=5000
       
       # 用户级配置 ~/.bashrc
       alias ll='ls -alh'
       
       # 环境变量优先级
       /etc/environment → /etc/profile → ~/.bash_profile
       ```

     6. 多级权限委托案例
       ```bash
       # 允许user1以operator身份执行特定命令
       Cmnd_Alias SERVICE_CTL = /usr/bin/systemctl start httpd, /usr/bin/systemctl stop httpd
       user1 ALL=(operator) SERVICE_CTL
       
       # 带时间限制的临时权限
       # 安装临时权限包
       yum install -y sudo_timeout
       
       # 配置30分钟后过期的权限
       Defaults timestamp_timeout=30
       
       # 审计日志配置
       Defaults logfile=/var/log/sudo_audit.log
       ```

   - 操作示例：
     ```bash
     # 创建用户
     useradd testuser
     
     # 设置用户密码
     passwd testuser
     
     # 创建用户组
     groupadd testgroup
     
     # 将用户加入组
     usermod -aG testgroup testuser
     
     # 配置sudo权限
     visudo
     # 添加：testuser ALL=(ALL) NOPASSWD:ALL
     
     # 查看用户信息
     id testuser
     ```
#### 逻辑存储管理
3. 文件系统管理
   - 操作流程
     * 创建
     * 验证
     * 排错
   - 学习内容：
     * 文件压缩与解压缩
     * 文件打包与解包
     * 文件系统检查与修复
   - 操作示例：
     ```bash
     # 使用gzip压缩文件
     gzip file.txt
     
     # 解压缩gzip文件
     gunzip file.txt.gz
     
     # 使用bzip2压缩文件
     bzip2 file.txt
     
     # 解压缩bzip2文件
     bunzip2 file.txt.bz2
     
     # 使用tar打包文件
     tar -cvf archive.tar file1 file2
     
     # 解包tar文件
     tar -xvf archive.tar
     
     # 使用tar.gz压缩
     tar -czvf archive.tar.gz file1 file2
     
     # 解压缩tar.gz
     tar -xzvf archive.tar.gz
     
     # 检查文件系统
     fsck /dev/sda1
     
     # 修复文件系统
     fsck -y /dev/sda1
     ```
4. 服务管理与配置
#### 服务配置管理
- 配置方法
   - 操作流程
     * 创建
     * 验证
     * 排错
#### 服务监控策略
- 实现方案
   - 操作流程
     * 创建
     * 验证
     * 排错
#### 故障排除方法
- 诊断流程
   - 操作流程
     * 创建
     * 验证
     * 排错
   - 学习内容：
     * 服务的基本概念与生命周期
     * 服务的启动、停止与重启
     * 服务状态查看与日志管理
     * 服务依赖关系管理
   - 操作示例：
     ```bash
     # 查看服务状态
     systemctl status sshd
     
     # 启动服务
     systemctl start sshd
     
     # 停止服务
     systemctl stop sshd
     
     # 重启服务
     systemctl restart sshd
     
     # 设置服务开机自启
     systemctl enable sshd
     
     # 禁用服务开机自启
     systemctl disable sshd
     
     # 查看服务日志
     journalctl -u sshd
     # 查看实时日志
     journalctl -f
     # 查看指定时间范围的日志
     journalctl --since "2023-01-01 00:00:00" --until "2023-01-31 23:59:59"
     # 查看指定优先级的日志
     journalctl -p err
     # 查看指定服务的日志
     journalctl -u nginx.service
     # 查看系统启动日志
     journalctl -b
     # 查看系统日志文件
     tail -f /var/log/messages
     # 查看特定关键词的日志
     grep "error" /var/log/syslog
     # 查看日志文件最后100行
     tail -n 100 /var/log/secure
     # 查看日志文件大小
     du -sh /var/log/
     # 日志轮转配置
     vim /etc/logrotate.conf
     
     # 管理服务依赖
     systemctl list-dependencies sshd
     ```

## 模块二：网络配置与管理
### 接口绑定
- **学习内容**：
  * 理解bonding模式（active-backup, balance-rr, 802.3ad等）
  * 掌握bonding配置方法
  * 学习bonding状态监控与故障切换机制
- **操作示例**：
  ```bash
  # 创建bond0接口
  nmcli con add type bond ifname bond0 mode active-backup
  nmcli con add type ethernet ifname eth1 master bond0
  nmcli con add type ethernet ifname eth2 master bond0

  # 查看bond状态
  cat /proc/net/bonding/bond0

  # 故障切换测试
  ip link set eth1 down
  ip link set eth1 up
  ```
### 防火墙配置
   - 配置策略
      * 创建
      * 验证
      * 排错
   - 规则优化配置
      * 调优方法
      * 创建
      * 验证
      * 排错
3. 网络服务管理
4. 网络故障排查

## 模块三：存储管理
### 磁盘管理
### 逻辑卷管理
### VDO存储优化
### 考核目标：
#### 物理存储管理
1. 磁盘管理与分区
   - 操作流程
     * 创建
     * 验证
     * 排错
2. 逻辑卷管理
   - 操作流程
     * 创建
     * 验证
     * 排错
#### 逻辑存储管理
3. 文件系统管理
   - 操作流程
     * 创建
     * 验证
     * 排错
   - 学习内容：
     * 文件压缩与解压缩
     * 文件打包与解包
     * 文件系统检查与修复
   - 操作示例：
     ```bash
     # 使用gzip压缩文件
     gzip file.txt
     
     # 解压缩gzip文件
     gunzip file.txt.gz
     
     # 使用bzip2压缩文件
     bzip2 file.txt
     
     # 解压缩bzip2文件
     bunzip2 file.txt.bz2
     
     # 使用tar打包文件
     tar -cvf archive.tar file1 file2
     
     # 解包tar文件
     tar -xvf archive.tar
     
     # 使用tar.gz压缩
     tar -czvf archive.tar.gz file1 file2
     
     # 解压缩tar.gz
     tar -xzvf archive.tar.gz
     
     # 检查文件系统
     fsck /dev/sda1
     
     # 修复文件系统
     fsck -y /dev/sda1
     ```
4. 存储加密与解密

#### VDO存储优化
5. VDO存储优化技术
   - 操作流程
     * 创建
     * 验证
     * 排错
   - 学习内容：
     * VDO（Virtual Data Optimizer）工作原理：基于删重和压缩技术优化存储空间
     * VDO卷创建与管理方法
     * 性能调优与监控技巧
   - 操作示例：
     ```bash
     # 创建VDO卷
     vdo create --name=vdo1 --device=/dev/sdb --vdoLogicalSize=100G
     
     # 格式化并挂载
     mkfs.xfs /dev/mapper/vdo1
     mkdir /vdo-storage
     mount /dev/mapper/vdo1 /vdo-storage
     
     # 查看VDO状态
     vdostats --human-readable
     
     # 优化配置
     vdo modify --name=vdo1 --compression=enabled --deduplication=enabled
     
     # 调整逻辑块大小
     vdo growLogical --name=vdo1 --vdoLogicalSize=200G
     
     # 持久化挂载配置
     echo '/dev/mapper/vdo1 /vdo-storage xfs defaults,_netdev,x-systemd.requires=vdo.service 0 0' >> /etc/fstab
     ```
   - 性能优化：
     1. 确保系统内存充足（推荐4GB+）
     2. 定期执行vdostats监控空间利用率
     3. 根据负载类型调整块大小（4KB-16KB）
     4. 启用异步模式处理大文件
     5. 结合SSD存储提升删重效率

## 模块四：安全管理
### SELinux配置
### 防火墙策略
### 用户权限审计
### 考核目标：
1. 用户与组管理
2. 文件权限管理
3. SELinux配置
4. 审计与日志管理

## 模块五：高级系统配置
### 内核参数调优
### 系统服务优化
### 资源限制配置
### 考核目标：
1. 磁盘配额配置与管理
2. 内核参数调优实践
3. 存储加密与解密
4. 系统性能基线设置

## 模块六：Ansible高级场景
### 考核目标：
1. 核心概念与基础配置

2. 角色开发与模块化设计
   - 学习内容：
     * Ansible角色目录结构标准
       ```bash
       roles/
         common/
           tasks/main.yml
           handlers/main.yml
           defaults/main.yml
           vars/main.yml
           files/
           templates/
           meta/main.yml
       ```
     * 角色变量管理方法
       ```yaml
       # defaults/main.yml
       app_port: 8080
       
       # vars/main.yml
       db_connection: "{{ db_host }}:{{ db_port }}"
       ```
     * 任务拆分与复用技巧
       ```yaml
       # tasks/install.yml
       - name: Install packages
         yum:
           name: "{{ packages }}"
         loop:
           - httpd
           - mariadb
       
       # tasks/config.yml
       - name: Copy configuration
         template:
           src: my.cnf.j2
           dest: /etc/my.cnf
       ```
     * 角色依赖管理
       ```yaml
       # meta/main.yml
       dependencies:
         - role: common
           vars:
             security_level: high
         - role: nginx
           when: "enable_nginx == true"
       ```
   - 操作示例：
     ```bash
     # 创建角色目录结构
     ansible-galaxy init webserver_role
     
     # 安装角色依赖
     ansible-galaxy install -r requirements.yml
     
     # 调用带依赖的角色
     - hosts: web_servers
       roles:
         - role: webserver_role
           vars:
             max_workers: 8
     ```
   - 最佳实践：
     1. 使用ansible-lint进行语法检查
     2. 为每个角色维护独立的变量文件
     3. 使用tag进行任务分组执行
     4. 通过meta/main.yml声明角色依赖关系

3. 敏感变量加密处理
4. 自定义过滤器开发
5. 动态库存配置
   - 架构组成与控制节点管理
     ```bash
     # 控制节点要求
     sudo yum install ansible
     # 受管节点SSH配置
     ansible_ssh_private_key_file=~/.ssh/web.key
     ```
   - 多平台安装与配置优化
     ```bash
     # RedHat系
     sudo yum install ansible
     # Debian系
     sudo apt-get install ansible
     ```
   - Inventory静态/动态配置
     ```ini
     [web_servers]
     192.168.1.101 ansible_user=admin
     [db_servers:children]
     web_servers
     ```
2. 角色开发与模块化设计
2. 敏感变量加密处理
3. 自定义过滤器开发
4. 动态库存配置

## 模块七：系统监控与故障排查
### 考核目标：
1. 系统性能监控
2. 日志分析与故障排查
3. 系统备份与恢复
4. 系统安全审计

### 日志分析技术
#### 压缩日志分析
```bash
zgrep -m 5 -z "FATAL" /var/log/nginx/*.gz  # 分析压缩日志中的致命错误

# 参数详解：
# -z 处理gzip/bzip2/xz压缩文件
# -m 5 每个文件最多匹配5次
# 时间范围过滤格式：
# --since="YYYY-MM-DD HH:MM:SS"
# --until="YYYY-MM-DD HH:MM:SS"
# 1天=1440分钟=86400秒
# -z 指定处理压缩文件（支持gzip/bzip2/xz）
# -m 5 限制每个文件最多匹配5次
# -i 忽略大小写匹配
# -c 显示匹配行数统计
# -l 仅显示包含匹配项的文件名
# --color=always 保持颜色输出（适合管道传输）
# 时间范围过滤示例：
# zgrep 'error' /var/log/*.gz --since="2023-01-01" --until="2023-12-31"

# 组合使用示例：
# zgrep "404" /var/log/nginx/access.log.2.gz | awk '{print $7}' | sort | uniq -c

# 最佳实践：
1. 定期执行日志轮转配置（logrotate）
2. 监控压缩日志文件大小，避免存储空间耗尽
3. 结合自动化脚本实现异常模式告警
4. 保留历史日志至少6个月用于合规审计

## 模块八：容器与虚拟化
### 考核目标：
1. 容器管理
2. 虚拟化管理
3. 容器网络配置
4. 容器存储管理

## 模块九：自动化与编排
### 考核目标：
1. Ansible操作实践
   - Ad-hoc命令体系
     ```bash
     ansible all -m ping
     ansible web_servers -m shell -a "free -m"
     ```
   - 系统管理模块(yum/service)
     ```yaml
     - name: 安装nginx
       yum:
         name: nginx
         state: latest
     - name: 启动httpd
       service:
         name: httpd
         state: started
     ```
   - 文件操作模块(template/copy)
     ```yaml
     - name: 部署配置
       template:
         src: nginx.conf.j2
         dest: /etc/nginx/nginx.conf
     ```
   - 网络配置模块
     ```yaml
     - name: 配置防火墙
       firewalld:
         service: http
         permanent: yes
         state: enabled
     ```
2. Playbook开发
2. Ansible高级应用
3. 自动化脚本编写
4. 系统编排实践

## 模块十：综合实战
### 考核目标：
1. 综合系统管理
2. 网络与安全管理
3. 存储与性能管理
4. 自动化与编排实践