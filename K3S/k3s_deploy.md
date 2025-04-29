# K3S 部署指南

## 1. 文档概述

### 1.1 K3S简介

K3S是一个轻量级的Kubernetes发行版，专为IoT和Edge计算设计。它将所有必需的系统组件打包成一个小于100MB的二进制文件，完美适用于资源受限的环境。主要特点包括：

- 打包为单个二进制文件
- 资源占用小，适合边缘计算和IoT设备
- 默认使用SQLite作为数据存储
- 自动化TLS管理
- 内置本地存储提供程序
- 内置服务负载均衡器
- 简化安装和维护过程

### 1.2 系统要求

#### 最低配置要求

- 处理器：1核
- 内存：512MB RAM
- 硬盘：200MB可用空间
- 操作系统：
  - Linux x86_64
  - Linux ARM64
  - Linux ARMv7

#### 推荐配置

- 处理器：2核或更多
- 内存：2GB RAM或更多
- 硬盘：20GB可用空间
- 操作系统：最新版本的Ubuntu/Debian/RHEL/CentOS

#### 网络要求

- 6443端口：Kubernetes API Server
- 8472端口：Flannel VXLAN（如使用）
- 10250端口：Kubelet metrics
- 2379-2380端口：etcd（仅在HA模式下）

### 1.3 部署架构说明

K3S支持以下几种部署架构：

1. **单节点部署**
   - 适用于开发、测试环境
   - 所有组件运行在同一节点
   - 最简单的部署方式

2. **单Server多Agent部署**
   - 一个Server节点（控制平面）
   - 多个Agent节点（工作节点）
   - 适用于小型生产环境

3. **高可用部署**
   - 多个Server节点（控制平面）
   - 多个Agent节点（工作节点）
   - 外部数据库（MySQL、PostgreSQL等）
   - 适用于生产环境

```mermaid
graph TD
    A[负载均衡器] --> B[Server节点1]
    A --> C[Server节点2]
    A --> D[Server节点3]
    B --> E[外部数据库]
    C --> E
    D --> E
    B --> F[Agent节点1]
    B --> G[Agent节点2]
    C --> F
    C --> G
    D --> F
    D --> G
```

## 2. 单节点部署

### 2.1 环境准备

1. **系统更新**

```bash
# Ubuntu/Debian
sudo apt update && sudo apt upgrade -y

# RHEL/CentOS
sudo yum update -y
```

2. **关闭防火墙**（可选，建议在测试环境）

```bash
# Ubuntu/Debian
sudo ufw disable

# RHEL/CentOS
sudo systemctl disable firewalld
sudo systemctl stop firewalld
```

3. **禁用SWAP**（必需）

```bash
# 临时禁用
sudo swapoff -a

# 永久禁用（编辑/etc/fstab，注释掉swap行）
sudo sed -i '/swap/s/^/#/' /etc/fstab
```

4. **配置内核参数**

```bash
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

### 2.2 安装步骤

1. **下载并安装K3S**

```bash
# 使用官方安装脚本
curl -sfL https://get.k3s.io | sh -

# 或指定版本安装
# curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.26.4+k3s1 sh -
```

2. **验证安装**

```bash
# 检查服务状态
sudo systemctl status k3s

# 查看节点状态
sudo kubectl get nodes

# 查看所有命名空间的Pod
sudo kubectl get pods -A
```

### 2.3 验证部署

1. **部署测试应用**

```bash
# 部署Nginx测试
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort

# 查看部署状态
kubectl get deployment nginx
kubectl get pods
kubectl get svc nginx
```

2. **访问测试应用**

```bash
# 获取NodePort端口
kubectl get svc nginx
# 使用curl测试访问
curl localhost:<NodePort>
```

3. **检查系统组件状态**

```bash
# 检查所有系统Pod状态
kubectl get pods -n kube-system

# 检查集群信息
kubectl cluster-info

# 检查API版本
kubectl api-versions
```

### 2.4 基本配置

K3S的配置文件位于 `/etc/rancher/k3s/k3s.yaml`。以下是一些常用的配置选项：

1. **服务配置**
编辑 `/etc/systemd/system/k3s.service` 文件，可以添加以下配置：

```ini
[Service]
ExecStart=/usr/local/bin/k3s server \
    --tls-san your-domain.com \
    --data-dir /var/lib/rancher/k3s \
    --disable traefik \  # 如果不需要默认的Traefik Ingress
    --disable servicelb  # 如果不需要默认的ServiceLB
```

2. **环境变量配置**
创建 `/etc/default/k3s` 文件：

```bash
K3S_KUBECONFIG_MODE="644"
K3S_NODE_NAME="k3s-master"
```

3. **重启服务使配置生效**

```bash
sudo systemctl daemon-reload
sudo systemctl restart k3s
```

### 2.5 卸载方法

如果需要卸载K3S，可以使用以下命令：

```bash
# 对于Server节点
/usr/local/bin/k3s-uninstall.sh

# 对于Agent节点
/usr/local/bin/k3s-agent-uninstall.sh
```

## 3. 多节点集群部署

### 3.1 Server节点部署

Server节点（也称为master节点）是K3S集群的控制平面，负责管理整个集群。

1. **在第一个Server节点上安装K3S**

```bash
# 安装K3S server
curl -sfL https://get.k3s.io | sh -s - server \
    --cluster-init \
    --tls-san <FIXED_IP_OR_DNS_NAME> \
    --node-external-ip <EXTERNAL_IP>

# 获取token（用于其他节点加入集群）
sudo cat /var/lib/rancher/k3s/server/node-token
```

2. **配置环境变量**

```bash
# 设置KUBECONFIG环境变量
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# 验证集群状态
kubectl get nodes
```

### 3.2 Agent节点加入

Agent节点（也称为worker节点）用于运行实际的工作负载。

1. **准备Agent节点**

- 按照前面的"环境准备"步骤配置系统
- 确保Agent节点能够通过网络访问Server节点

2. **加入集群**

```bash
# 在Agent节点上运行以下命令
curl -sfL https://get.k3s.io | K3S_URL=https://<SERVER_IP>:6443 \
    K3S_TOKEN=<NODE_TOKEN> \
    sh -

# 检查节点状态（在Server节点上运行）
kubectl get nodes
```

### 3.3 高可用配置

对于生产环境，建议配置高可用(HA)集群。K3S支持两种HA配置方式：

#### 3.3.1 嵌入式etcd高可用

1. **部署第一个Server节点**

```bash
curl -sfL https://get.k3s.io | sh -s - server \
    --cluster-init \
    --tls-san <FIXED_IP_OR_DNS_NAME>
```

2. **添加其他Server节点**

```bash
curl -sfL https://get.k3s.io | sh -s - server \
    --server https://<FIRST_SERVER_IP>:6443 \
    --token <NODE_TOKEN> \
    --tls-san <FIXED_IP_OR_DNS_NAME>
```

#### 3.3.2 外部数据库高可用

1. **准备外部数据库**（以MySQL为例）

```sql
CREATE DATABASE k3s;
CREATE USER 'k3s'@'%' IDENTIFIED BY 'your-password';
GRANT ALL PRIVILEGES ON k3s.* TO 'k3s'@'%';
FLUSH PRIVILEGES;
```

2. **部署第一个Server节点**

```bash
curl -sfL https://get.k3s.io | sh -s - server \
    --datastore-endpoint="mysql://k3s:your-password@tcp(database-host:3306)/k3s" \
    --tls-san <FIXED_IP_OR_DNS_NAME>
```

3. **添加其他Server节点**

```bash
curl -sfL https://get.k3s.io | sh -s - server \
    --datastore-endpoint="mysql://k3s:your-password@tcp(database-host:3306)/k3s" \
    --tls-san <FIXED_IP_OR_DNS_NAME>
```

### 3.4 负载均衡配置

对于HA集群，建议配置负载均衡器来分发API请求。

#### 3.4.1 使用Nginx作为负载均衡器

1. **安装Nginx**

```bash
sudo apt update && sudo apt install nginx -y
```

2. **配置Nginx**

```nginx
# /etc/nginx/conf.d/k3s.conf
upstream k3s_servers {
    server <SERVER1_IP>:6443;
    server <SERVER2_IP>:6443;
    server <SERVER3_IP>:6443;
}

server {
    listen 6443;
    server_name _;

    location / {
        proxy_pass https://k3s_servers;
        proxy_connect_timeout 15s;
        proxy_send_timeout 15s;
        proxy_read_timeout 15s;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

3. **重启Nginx**

```bash
sudo nginx -t
sudo systemctl restart nginx
```

### 3.5 集群验证

1. **检查集群状态**

```bash
# 检查节点状态
kubectl get nodes -o wide

# 检查系统组件
kubectl get pods -n kube-system

# 检查集群信息
kubectl cluster-info
```

2. **测试集群功能**

```bash
# 部署测试应用
kubectl create deployment nginx --image=nginx --replicas=3
kubectl expose deployment nginx --port=80 --type=NodePort

# 验证Pod分布
kubectl get pods -o wide

# 验证服务访问
kubectl get svc nginx
```

3. **检查高可用功能**

```bash
# 模拟节点故障（在其中一个Server节点上执行）
sudo systemctl stop k3s

# 检查集群是否继续正常运行
kubectl get nodes
kubectl get pods -A
```

## 4. 配置说明

### 4.1 基本配置参数

K3S提供了多种配置选项，可以通过命令行参数或环境变量进行设置。

#### 4.1.1 常用命令行参数

| 参数 | 说明 | 示例 |
|------|------|------|
| --tls-san | 添加额外的主机名或IP到TLS证书 | --tls-san domain.com |
| --data-dir | 数据目录路径 | --data-dir /opt/k3s |
| --disable | 禁用组件 | --disable traefik |
| --docker | 使用Docker而不是默认的containerd | --docker |
| --flannel-backend | 设置Flannel后端 | --flannel-backend vxlan |

#### 4.1.2 重要环境变量

| 环境变量 | 说明 | 示例 |
|----------|------|------|
| K3S_TOKEN | 用于加入集群的token | export K3S_TOKEN=xxx |
| K3S_KUBECONFIG_MODE | kubeconfig文件权限 | export K3S_KUBECONFIG_MODE="644" |
| K3S_NODE_NAME | 节点名称 | export K3S_NODE_NAME=master-1 |
| INSTALL_K3S_VERSION | 安装特定版本 | export INSTALL_K3S_VERSION=v1.26.4+k3s1 |

### 4.2 网络配置

#### 4.2.1 CNI配置

K3S默认使用Flannel作为CNI插件，但也支持其他CNI插件：

1. **Flannel配置**

```bash
# 修改Flannel后端
kubectl edit cm/flannel-config -n kube-system

# 配置示例
data:
  flannel-config.json: |
    {
      "Network": "10.42.0.0/16",
      "Backend": {
        "Type": "vxlan"
      }
    }
```

2. **使用Calico**

```bash
# 安装K3S时禁用默认CNI
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--flannel-backend none" sh -

# 安装Calico
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
```

#### 4.2.2 Service网络配置

1. **修改Service CIDR**

```bash
# 安装时指定Service CIDR
curl -sfL https://get.k3s.io | sh -s - --service-cidr 10.43.0.0/16
```

2. **配置ServiceLB**

```yaml
# 创建Service LoadBalancer配置
apiVersion: v1
kind: Service
metadata:
  name: nginx-lb
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 80
  selector:
    app: nginx
```

### 4.3 存储配置

K3S提供了多种存储选项：

#### 4.3.1 Local Path Provisioner

默认启用的存储提供者，适用于单节点部署：

```yaml
# 创建PVC示例
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: local-path-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 1Gi
```

#### 4.3.2 Longhorn

适用于多节点集群的分布式存储解决方案：

1. **安装Longhorn**

```bash
# 安装Longhorn
kubectl apply -f https://raw.githubusercontent.com/longhorn/longhorn/master/deploy/longhorn.yaml

# 等待Longhorn组件就绪
kubectl -n longhorn-system get pods
```

2. **使用Longhorn存储**

```yaml
# 创建使用Longhorn的PVC
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: longhorn-pvc
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: longhorn
  resources:
    requests:
      storage: 1Gi
```

#### 4.3.3 NFS存储

对于需要使用外部NFS存储的场景：

1. **安装NFS客户端**

```bash
# Ubuntu/Debian
sudo apt install -y nfs-common

# RHEL/CentOS
sudo yum install -y nfs-utils
```

2. **部署NFS Provisioner**

```bash
# 使用Helm安装NFS Provisioner
helm repo add nfs-subdir-external-provisioner https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner/
helm install nfs-subdir-external-provisioner nfs-subdir-external-provisioner/nfs-subdir-external-provisioner \
    --set nfs.server=x.x.x.x \
    --set nfs.path=/exported/path
```

3. **创建使用NFS的PVC**

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nfs-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: nfs-client
  resources:
    requests:
      storage: 1Gi
```

### 4.4 资源限制配置

#### 4.4.1 节点资源限制

```yaml
# 为节点添加标签和污点
kubectl label node <node-name> node-role.kubernetes.io/worker=true
kubectl taint nodes <node-name> key=value:NoSchedule

# 配置节点资源限制
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  name: high-performance
handler: runc
scheduling:
  nodeSelector:
    node-role.kubernetes.io/worker: "true"
  tolerations:
  - key: "key"
    operator: "Equal"
    value: "value"
    effect: "NoSchedule"
```

#### 4.4.2 命名空间资源配额

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: project-1
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
```

## 5. 常见问题和故障排除

### 5.1 安装问题

#### 5.1.1 安装失败

1. **系统要求不满足**

```bash
# 检查系统资源
free -m
df -h
nproc

# 检查系统日志
journalctl -u k3s
```

2. **网络问题**

```bash
# 检查必要端口
sudo netstat -tlpn | grep -E '6443|8472|10250'

# 检查DNS解析
nslookup <SERVER_NAME>

# 检查网络连通性
curl -k https://<SERVER_IP>:6443
```

#### 5.1.2 节点加入失败

1. **Token问题**

```bash
# 在Server节点重新获取token
sudo cat /var/lib/rancher/k3s/server/node-token

# 检查Agent节点的k3s日志
journalctl -u k3s-agent -f
```

2. **网络连接问题**

```bash
# 检查Agent到Server的连接
curl -k https://<SERVER_IP>:6443

# 检查防火墙规则
sudo iptables -L
```

### 5.2 网络问题

#### 5.2.1 Pod网络通信问题

1. **检查CNI状态**

```bash
# 检查CNI pods状态
kubectl get pods -n kube-system | grep flannel

# 检查CNI日志
kubectl logs -n kube-system <flannel-pod-name>
```

2. **检查网络策略**

```bash
# 查看网络策略
kubectl get networkpolicies --all-namespaces

# 测试Pod间通信
kubectl exec -it <pod-name> -- ping <other-pod-ip>
```

#### 5.2.2 Service访问问题

1. **检查Service配置**

```bash
# 查看Service详情
kubectl describe svc <service-name>

# 检查Endpoints
kubectl get endpoints <service-name>
```

2. **检查kube-proxy**

```bash
# 查看kube-proxy日志
kubectl logs -n kube-system -l k8s-app=kube-proxy

# 检查iptables规则
sudo iptables-save | grep <service-name>
```

### 5.3 性能调优

#### 5.3.1 节点性能优化

1. **系统级优化**

```bash
# 调整系统限制
cat <<EOF | sudo tee /etc/sysctl.d/k8s-performance.conf
vm.swappiness = 0
vm.dirty_ratio = 30
vm.dirty_background_ratio = 5
fs.inotify.max_user_watches = 524288
EOF

sudo sysctl --system
```

2. **容器运行时优化**

```bash
# containerd配置优化
cat <<EOF | sudo tee /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri"]
  enable_tls_streaming = true
  stream_server_address = "127.0.0.1"
  stream_server_port = "10010"
  max_container_log_line_size = 16384
EOF

sudo systemctl restart containerd
```

## 6. 最佳实践

### 6.1 安全建议

#### 6.1.1 基础安全配置

1. **API Server安全**

```bash
# 配置API Server审计日志
cat <<EOF | sudo tee /var/lib/rancher/k3s/server/audit.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
EOF

# 启用审计日志
sudo k3s server --kube-apiserver-arg="audit-log-path=/var/log/k3s-audit.log" --kube-apiserver-arg="audit-policy-file=/var/lib/rancher/k3s/server/audit.yaml"
```

2. **网络安全**

```yaml
# 创建默认网络策略
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: default
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

#### 6.1.2 访问控制

1. **RBAC配置**

```yaml
# 创建受限用户角色
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list"]
```

2. **Secret管理**

```bash
# 使用加密配置
sudo k3s server --secrets-encryption

# 定期轮换密钥
kubectl -n kube-system create secret generic my-secret --from-literal=key=value
```

### 6.2 备份恢复

#### 6.2.1 etcd备份

1. **自动备份**

```bash
# 配置自动备份
sudo k3s server --etcd-snapshot-schedule-cron="0 */6 * * *" \
    --etcd-snapshot-retention=5 \
    --etcd-snapshot-dir=/opt/k3s-backups
```

2. **手动备份**

```bash
# 创建快照
sudo k3s etcd-snapshot save --name pre-upgrade-snapshot

# 列出快照
sudo k3s etcd-snapshot ls
```

#### 6.2.2 恢复操作

```bash
# 从快照恢复
sudo k3s server --cluster-reset \
    --cluster-reset-restore-path=/var/lib/rancher/k3s/server/db/snapshots/snapshot-name.db
```

### 6.3 升级策略

#### 6.3.1 升级准备

1. **升级前检查**

```bash
# 检查当前版本
kubectl version --short

# 备份etcd
sudo k3s etcd-snapshot save

# 检查集群健康状态
kubectl get nodes
kubectl get pods --all-namespaces
```

2. **制定升级计划**

- 选择合适的维护窗口
- 准备回滚方案
- 通知相关团队

#### 6.3.2 执行升级

1. **单节点集群升级**

```bash
# 安装新版本
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.26.4+k3s1 sh -
```

2. **多节点集群升级**

```bash
# 升级Server节点
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.26.4+k3s1 sh -

# 升级Agent节点
curl -sfL https://get.k3s.io | INSTALL_K3S_VERSION=v1.26.4+k3s1 K3S_URL=https://<SERVER_IP>:6443 K3S_TOKEN=<NODE_TOKEN> sh -
```

### 6.4 监控和日志

#### 6.4.1 监控配置

1. **部署Prometheus**

```bash
# 使用Helm安装Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack
```

2. **配置告警规则**

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: k3s-alerts
  namespace: monitoring
spec:
  groups:
  - name: k3s
    rules:
    - alert: NodeNotReady
      expr: kube_node_status_condition{condition="Ready",status="true"} == 0
      for: 5m
      labels:
        severity: critical
```

#### 6.4.2 日志管理

1. **部署EFK栈**

```bash
# 安装Elasticsearch
kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/2.8.0/operator.yaml

# 配置Fluentd
kubectl create namespace logging
kubectl apply -f fluentd-configmap.yaml
kubectl apply -f fluentd-daemonset.yaml
```

2. **日志轮换**

```bash
# 配置containerd日志轮换
cat <<EOF | sudo tee /etc/containerd/config.toml
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
  SystemdCgroup = true
[plugins."io.containerd.grpc.v1.cri".containerd]
  snapshotter = "overlayfs"
  disable_snapshot_annotations = true
[plugins."io.containerd.grpc.v1.cri".containerd.log_opts]
  max-size = "100m"
  max-file = "3"
EOF
```
