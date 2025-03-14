## 角色定义 | Role Definition

### 执行机 (Controller Machine)
- 运行部署脚本的机器 | Machine running deployment scripts
- 支持 Linux/Windows 系统（Windows 无需 WSL 环境） | Supports Linux/Windows systems (No WSL required for Windows)

### 主控机 (Master Node)
- 运行 PackStack 的机器 | Machine running PackStack
- 负责生成应答文件并执行部署 | Responsible for generating answer files and executing deployment

### 目标机 (Target Node)
- 实际部署 OpenStack 的机器 | Physical machine deploying OpenStack

## 环境检查要求

### 操作系统要求
1. 操作系统类型
   - 主控机 & 目标机：CentOS 系列操作系统
   - 版本要求：CentOS Stream 9

2. 网络配置
   ```bash
   ping -c 4 <目标IP>  # 检查节点间网络连通性 (Check inter-node connectivity)
   ```
   - 主控机与目标机需保持网络畅通 (Require stable network connection between master and target nodes)

3. 安全配置（目标机）
   ```bash
   sudo setenforce 0            # 禁用SELinux（重启后生效）| Disable SELinux (persist after reboot)
   sudo systemctl stop firewalld --now  # 停止并禁用防火墙 | Stop and disable firewall
   sudo systemctl disable NetworkManager  # 禁用网络管理器 | Disable NetworkManager
   ```

## 部署流程
### 阶段一：环境准备
1. sudo权限验证
```bash
sudo -v || { echo "需要管理员权限"; exit 1; }  # 验证sudo权限
```
2. 主控机网络检测
### 步骤1：仓库配置
1. 版本自动发现

```bash
vName=$(dnf search centos-release-openstack-* | grep -Po 'centos-release-openstack-\K\w+' | sort -Vr | head -1)
[ -z "$vName" ] && { echo "未找到可用仓库版本"; exit 1; }
```

2. 版本选择
   - 获取所有可用版本列表
   - 按序号排序供用户选择

3. 仓库安装

```bash
sudo dnf install -y centos-release-openstack-$vName
```
   - 安装失败时自动终止并提示网络检查

### 步骤2：PackStack 安装
```bash
sudo dnf install -y openstack-packstack  # 安装 PackStack
```

### 步骤3：应答文件生成
```bash
envsubst < packstack_answer_template.j2 > answer.txt  # 使用环境变量渲染模板
```

### 步骤4：应答文件配置
```ini
# Neutron 网络配置 (Neutron Network Configuration)
CONFIG_NEUTRON_OVS_BRIDGE_IFACES={{ network_interface }}  # 指定网络接口
CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS=openvswitch
CONFIG_NEUTRON_L2_AGENT=openvswitch
CONFIG_NEUTRON_VPNAAS=y                 # 启用VPN即服务功能 (Enable VPN-as-a-Service)

# 节点配置 (Node Configuration)
CONFIG_COMPUTE_HOSTS=<目标机IP>  # 指定计算节点IP（多个IP用逗号分隔）
                                 # 示例：192.168.1.100,192.168.1.101
```

### 步骤5：部署执行
```bash
packstack --answer-file=answer.txt | tee deployment.log  # 同时输出到控制台和日志文件
```

### 步骤6：结果验证
1. 部署状态监控
   - 实时显示部署进度
   - 错误信息实时回传至执行机

2. 成功通知
   - 返回 OpenStack 访问信息
   - 包含 Dashboard URL 及初始凭证

3. 环境变量加载
   ```bash
   source /root/keystonerc_admin  # 加载管理凭证（每次会话需要重新加载）
   ```