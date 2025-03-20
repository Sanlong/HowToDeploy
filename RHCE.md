# RHCE 9 详细考试大纲

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

# RHCE 9 详细考试大纲

## 模块一：基础系统管理
### 文件系统基础
#### 系统目录结构解析

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