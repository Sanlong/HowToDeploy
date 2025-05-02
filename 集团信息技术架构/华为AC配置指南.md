# 华为AirEngine 9700S-S AC控制器配置指南

## 1. 设备概述

### 1.1 硬件规格
- 型号：AirEngine 9700S-S
- 最大AP管理数：1024
- 最大并发用户数：40K
- 交换容量：480Gbps
- 转发性能：180Mpps

### 1.2 特性支持
- 支持WPA3企业级认证
- 支持802.1X认证
- 支持RADIUS服务器对接
- 支持本地转发和集中转发
- 支持智能负载均衡

## 2. 基础配置

### 2.1 初始化配置
```
# 进入系统视图
system-view

# 配置设备名称
sysname AC-MAIN

# 配置管理IP地址
vlanif 1
ip address 10.0.0.10 255.255.255.0

# 配置默认路由
ip route-static 0.0.0.0 0.0.0.0 10.0.0.1

# 配置NTP服务器
ntp-service unicast-server 10.0.0.2
```

### 2.2 VLAN配置
```
# 创建管理VLAN
vlan 10
description MGMT-VLAN

# 创建企业用户VLAN
vlan 20
description CORP-VLAN

# 创建BYOD设备VLAN
vlan 30
description BYOD-VLAN

# 创建访客VLAN
vlan 40
description GUEST-VLAN
```

## 3. WLAN服务配置

### 3.1 域设备SSID（隐藏）
```
# 创建安全域
security-profile name CORP-HIDDEN
 security wpa2 psk pass-phrase Encrypted-PSK-Here mode aes
 security wpa3 authentication enterprise
 security wpa3 encryption aes
 security authentication-method dot1x

# 配置WLAN服务
wlan-service service-set name CORP-HIDDEN
 ssid CORP-HIDDEN
 hidden-ssid enable
 service-vlan 20
 security-profile name CORP-HIDDEN
 forward-mode tunnel
```

### 3.2 BYOD设备SSID
```
# 创建安全域
security-profile name CORP-BYOD
 security wpa3 authentication enterprise
 security wpa3 encryption aes
 security authentication-method dot1x

# 配置WLAN服务
wlan-service service-set name CORP-BYOD
 ssid CORP-BYOD
 service-vlan 30
 security-profile name CORP-BYOD
 forward-mode tunnel
```

## 4. RADIUS配置

### 4.1 RADIUS服务器配置
```
# 配置RADIUS方案
radius-server template corp-radius
 radius-server authentication 10.0.0.20 1812
 radius-server accounting 10.0.0.20 1813
 radius-server shared-key cipher your-shared-key
 radius-server retry 2
 radius-server timeout 5

# 配置AAA方案
aaa
 authentication-scheme corp-auth
  authentication-mode radius
 authorization-scheme corp-author
  authorization-mode radius
 accounting-scheme corp-acct
  accounting-mode radius
```

### 4.2 域配置
```
# 配置认证域
domain corp.com
 authentication-scheme corp-auth
 authorization-scheme corp-author
 accounting-scheme corp-acct
 radius-server corp-radius
```

## 5. AP管理配置

### 5.1 AP组配置
```
# 创建AP组
wlan ap-group name CORP-AP-GROUP
 
# 配置AP模板
ap-template name CORP-AP-TEMPLATE
 ap-type 9700s
 radio 0
  radio-type 802.11b/g/n/ac/ax
 radio 1
  radio-type 802.11a/n/ac/ax
```

### 5.2 AP自动发现配置
```
# 配置DHCP Option 43
dhcp server option 43 hex 01040A000A0A

# 配置AP认证
ap-auth-mode mac-auth
ap-mac-auth-template name default_ap_auth
```

## 6. 射频优化配置

### 6.1 射频管理
```
# 配置射频参数
wlan ap-group name CORP-AP-GROUP
 radio 0
  channel auto
  power auto
  rate-limit
 radio 1
  channel auto
  power auto
  rate-limit
```

### 6.2 负载均衡
```
# 配置负载均衡
wlan ap-group name CORP-AP-GROUP
 load-balance enable
 load-balance traffic-threshold 70
 load-balance user-threshold 30
```

## 7. QoS配置

### 7.1 业务优先级
```
# 配置QoS策略
traffic classifier VOIP
 if-match dscp ef
traffic behavior VOIP
 priority 6

traffic classifier VIDEO
 if-match dscp af41
traffic behavior VIDEO
 priority 4

# 应用QoS策略
traffic policy CORP-QOS
 classifier VOIP behavior VOIP
 classifier VIDEO behavior VIDEO
```

### 7.2 带宽控制
```
# 配置带宽限制
wlan service-set name CORP-BYOD
 client-rate-limit up 4096 down 8192
```

## 8. 监控告警配置

### 8.1 SNMP配置
```
# 配置SNMP
snmp-agent
snmp-agent community read cipher SNMP-RO
snmp-agent community write cipher SNMP-RW
snmp-agent sys-info version v2c v3
```

### 8.2 系统日志配置
```
# 配置Syslog
info-center enable
info-center source default channel 1 log level notification
info-center loghost 10.0.0.5
```

## 9. 高可用性配置

### 9.1 AC备份
```
# 配置AC备份
ac-backup peer 10.0.0.11
ac-backup authentication-key cipher BACKUP-KEY
ac-backup priority 100
```

### 9.2 链路聚合
```
# 配置链路聚合
interface Eth-Trunk 1
 mode lacp-static
 trunkport GigabitEthernet 0/0/1
 trunkport GigabitEthernet 0/0/2
```

## 10. 配置验证

### 10.1 基本检查命令
```
# 查看系统状态
display version
display device

# 查看WLAN配置
display wlan service-set all
display wlan client

# 查看AP状态
display ap all
display ap-group all

# 查看RADIUS状态
display radius-server statistics
```

### 10.2 故障排查命令
```
# 查看日志
display logbuffer

# 查看接口状态
display interface brief

# 查看RADIUS认证
display radius-server statistics

# 查看客户端状态
display station-info
```

## 11. 日常维护建议

### 11.1 定期检查项目
1. AP在线状态监控
2. 客户端连接质量检查
3. 系统日志审计
4. 配置文件备份
5. 固件版本更新评估

### 11.2 性能优化建议
1. 定期进行射频优化
2. 监控信道利用率
3. 评估负载均衡效果
4. 检查QoS策略效果
5. 分析用户分布情况