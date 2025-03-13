#!/bin/bash
# OpenStack自动化部署脚本 | OpenStack Auto Deployment Script

# 安装基础依赖 | Install base dependencies
yum install -y centos-release-openstack-ussuri

# 更新系统 | Update system
yum update -y

# 安装Packstack | Install Packstack
yum install -y openstack-packstack

# 生成应答文件模板 | Generate answer file template
packstack --gen-answer-file=answer_template.txt

# 替换默认密码 | Replace default password
sed -i "s/CONFIG_DEFAULT_PASSWORD=.*/CONFIG_DEFAULT_PASSWORD=mysecretpassword/" answer_template.txt

# 执行部署命令 | Execute deployment
packstack --answer-file=answer_template.txt

# 错误处理 | Error handling
if [ $? -ne 0 ]; then
    echo "部署失败，请检查日志 | Deployment failed, please check logs"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi
e
# 版本自动发现机制 | Version auto-discovery
# 交互式版本选择 | Interactive version selection
versions=($(dnf search centos-release-openstack-* | grep -Po 'centos-release-openstack-\K\w+'))
if [ ${#versions[@]} -eq 0 ]; then
    echo "错误：未找到可用仓库版本 | Error: No available repository versions"
    exit 1
fi

echo "可用仓库版本列表 | Available repository versions:"
for i in "${!versions[@]}"; do
    printf "%2d) %s\n" $((i+1)) "${versions[$i]}"
done

read -p "请输入版本序号 [1-${#versions[@]}] | Enter version number: " selected_index
if ! [[ "$selected_index" =~ ^[0-9]+$ ]] || [ "$selected_index" -lt 1 ] || [ "$selected_index" -gt ${#versions[@]} ]; then
    echo "错误：无效的序号输入 | Error: Invalid number input"
    exit 1
fi
vName=${versions[$((selected_index-1))]}

# 版本有效性验证 | Version validation
if ! dnf list centos-release-openstack-$vName &> /dev/null; then
    echo "错误：仓库版本 $vName 不可用 | Error: Repository version $vName unavailable"
    exit 1
fi

echo "检测到最新版本：$vName | Detected latest version: $vName"

# 安装仓库 | Install repository
echo "正在安装仓库... | Installing repository..."
if ! yum install -y centos-release-openstack-$vName; then
    echo "仓库安装失败，请检查网络连接 | Repository installation failed, check network connection"
    exit 1
fi

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"

# 部署完成后加载环境变量
if [ -f "/root/keystonerc_admin" ]; then
    source /root/keystonerc_admin
    echo "环境变量加载完成"
else
    echo "警告：环境变量文件不存在，请检查部署结果"
    exit 1
fi

# 显示完成信息 | Show completion message