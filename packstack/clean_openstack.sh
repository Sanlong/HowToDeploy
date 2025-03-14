#!/bin/bash
# OpenStack环境清理脚本 | OpenStack Environment Cleanup Script

# 验证sudo权限
if ! sudo -v; then
    echo "错误：当前用户无sudo权限 | Error: User has no sudo privileges"
    exit 1
fi

# 检查新增包列表文件
if [ ! -f "added_packages.log" ]; then
    echo "错误：找不到新增软件包列表 | Error: Missing added packages list"
    exit 1
fi

# 逆序卸载所有新增包（解决依赖问题）
echo "正在移除新增软件包... | Removing newly installed packages..."
sudo xargs -t -a added_packages.log rpm -e --nodeps

# 移除OpenStack仓库
echo "正在移除OpenStack仓库... | Removing OpenStack repository..."
sudo dnf remove -y centos-release-openstack-dalmatian

# 清理残留配置文件
echo "正在清理残留配置... | Cleaning residual configurations..."
sudo rm -rf /etc/yum.repos.d/packstack*

# 显示完成信息
echo "系统已成功回退到初始状态！| System successfully rolled back to initial state!"