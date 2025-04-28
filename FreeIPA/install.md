# FreeIPA 部署指南

## 系统要求
- 操作系统: CentOS/RHEL 7/8 或 Fedora
- 内存: 至少4GB
- 磁盘空间: 至少10GB
- 网络: 静态IP地址配置
- 主机名: 必须配置正确且可解析

## 安装步骤
1. 更新系统:
   ```bash
   sudo yum update -y
   ```

2. 安装FreeIPA服务端:
   ```bash
   sudo yum install -y ipa-server ipa-server-dns
   ```

3. 运行安装向导:
   ```bash
   sudo ipa-server-install
   ```
   - 按照提示输入域名、realm名称等信息
   - 设置管理员密码

4. 配置防火墙:
   ```bash
   sudo firewall-cmd --add-service={freeipa-ldap,freeipa-ldaps} --permanent
   sudo firewall-cmd --reload
   ```

## 验证安装
1. 检查服务状态:
   ```bash
   sudo ipactl status
   ```

2. 测试管理员登录:
   ```bash
   kinit admin
   ```

3. 查看用户列表:
   ```bash
   ipa user-find
   ```

## 高可用部署

### 多节点配置
1. 在主节点上安装FreeIPA服务端后，在副本节点上运行:
   ```bash
   sudo ipa-replica-install --setup-ca --setup-dns --no-forwarders
   ```

### 数据同步
- FreeIPA使用多主复制架构，数据变更会自动同步到所有节点
- 可通过以下命令检查复制状态:
   ```bash
   ipa-replica-manage list
   ```

### 故障转移
- 使用DNS SRV记录实现负载均衡和故障转移
- 示例DNS配置:
   ```
   _ldap._tcp.example.com. 86400 IN SRV 0 100 389 ipa1.example.com.
   _ldap._tcp.example.com. 86400 IN SRV 1 100 389 ipa2.example.com.
   ```

### 证书同步
- CA证书会自动在所有节点间同步
- 手动同步命令:
   ```bash
   ipa-cacert-manage renew
   ```

## 常见问题
- 确保SELinux处于enforcing或permissive模式
- 安装前确保时间同步(NTP)配置正确
- 如果使用DNS，确保反向DNS记录配置正确