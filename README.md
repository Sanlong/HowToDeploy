# HowToDeploy

自动化部署工具集合

## 项目结构

```
HowToDeploy/
├── packstack/          # OpenStack部署工具
│   ├── auto_grader.py # 自动评分工具
│   └── details.md     # 部署说明文档
├── awx_depoly/        # AWX部署工具
│   └── remote_runner.py # 远程部署脚本
└── README.md          # 项目说明文档
```

## 使用说明

1. OpenStack部署
   - 参考 `packstack/details.md`
   - 使用 `auto_grader.py` 验证部署

2. AWX部署
   - 运行 `remote_runner.py` 进行远程部署
   - 支持断点续传和自动重试

## 开发指南

详见各子目录下的说明文档。

# HowToDeploy

## 项目概述
自动化部署工具集合，包含多种基础设施的一键部署方案

## 包含组件
- 🚀 AWX自动化部署
- 📊 Zabbix监控系统部署
- ☁️ PackStack OpenStack私有云部署

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
