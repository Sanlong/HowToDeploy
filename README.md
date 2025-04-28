# uselinux

## 项目结构

```

HowToDeploy/
├── Ansible/            # Ansible自动化部署
├── Calico/            # 网络策略管理
├── Consul/            # 服务发现与配置
├── ELK/               # 日志分析系统
│   ├── Elasticsearch/
│   ├── Kibana/
│   └── Logstash/
├── ETCD/              # 分布式键值存储
├── FreeIPA/           # 身份管理系统
├── Grafana/           # 监控可视化
├── HAProxy/           # 负载均衡
├── Kafka/             # 消息队列
├── k8s/               # Kubernetes部署
├── OpenStack/         # 私有云部署
│   ├── Ceph/
│   ├── Ironic/
│   ├── Magnum/
│   └── Neutron/
├── Prometheus/        # 监控系统
├── RabbitMQ/          # 消息代理
├── Valkey(Redis)/     # 缓存数据库
├── Zabbix/            # 监控系统
└── Zookeeper/         # 分布式协调服务
```

## 使用说明

1. OpenStack部署
   - 参考 `OpenStack/packstack-README.md`
   - 使用 `OpenStack/packstack-answer-dalmatian.md` 配置文件

2. AWX部署
   - 运行 `Ansible/install_podman.yml` 准备环境
   - 执行 `Ansible/podman.ansible.yml` 部署AWX

3. Zabbix部署
   - 运行 `zabbix/deploy_zabbix.sh` 脚本
   - 支持自定义监控项配置

4. ETCD集群部署
   - 参考 `ETCD/cluster.md` 多节点部署
   - 参考 `ETCD/singleHost.md` 单节点部署

## 开发指南

详见各子目录下的说明文档。

# HowToDeploy

## 项目概述

自动化部署工具集合，包含多种基础设施的一键部署方案

## 包含组件

- 🚀 AWX自动化部署
- 📊 Zabbix监控系统部署
- ☁️ OpenStack私有云部署
- 🔍 Prometheus监控系统
- 🐳 Kubernetes集群部署
- 🐇 RabbitMQ消息队列
- 🗃️ ETCD分布式存储
- 🔥 Valkey(Redis)缓存服务
- 🕸️ Calico网络策略
- 📈 Grafana可视化

## 使用说明

1. 进入具体组件目录查看部署指南
2. 所有脚本均需在CentOS Stream 9环境运行
3. 执行前请仔细阅读各组件README中的注意事项

## 贡献指南

欢迎通过Issue提交问题或Pull Request贡献改进方案

## 版权信息

Apache License 2.0

# 项目简介 | Project Introduction

自动化部署工具集合，包含OpenStack、AWX、Zabbix等基础设施的部署脚本。
| Automation deployment toolkit containing scripts for infrastructure deployment including OpenStack, AWX, Zabbix etc.

## 功能特性 | Features

- 支持多平台部署 | Multi-platform deployment support
- 提供完整的日志记录 | Complete logging capabilities
- 包含预部署检查 | Pre-deployment checks included

## 快速开始 | Quick Start

```bash
# 克隆仓库 | Clone repository
git clone https://github.com/yourrepo/HowToDeploy.git

# 安装依赖 | Install dependencies
pip install -r requirements.txt
```

my personal install steps
