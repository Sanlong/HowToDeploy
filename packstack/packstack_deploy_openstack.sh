#!/bin/bash
# OpenStack自动化部署脚本 | OpenStack Auto Deployment Script

# 记录初始软件包状态
echo "正在记录系统当前软件包状态... | Recording current package status..."
rpm -qa | sort > installed_packages_before.log

# 检查sudo权限
if ! sudo -v; then
    echo "错误：当前用户无sudo权限 | Error: User has no sudo privileges"
    exit 1
fi

# SELinux状态检查与配置
current_se_mode=$(getenforce)
if [[ "$current_se_mode" != "Disabled" && "$current_se_mode" != "Permissive" ]]; then
    echo "正在配置SELinux为Permissive模式 | Configuring SELinux to Permissive mode..."
    sudo sed -i 's/^SELINUX=.*/SELINUX=permissive/' /etc/selinux/config
    if ! sudo setenforce Permissive; then
        echo "错误：无法临时修改SELinux模式 | Error: Failed to set temporary SELinux mode"
        exit 1
    fi
fi

# 防火墙服务检查
if systemctl is-active --quiet firewalld; then
    echo "正在关闭防火墙服务 | Stopping firewalld service..."
    if ! sudo systemctl stop firewalld --now && sudo systemctl disable firewalld; then
        echo "错误：防火墙关闭失败 | Error: Failed to disable firewalld"
        exit 1
    fi
fi

# NetworkManager服务管理
if systemctl is-active --quiet NetworkManager; then
    echo "正在关闭NetworkManager服务 | Stopping NetworkManager service..."
    if ! sudo systemctl stop NetworkManager --now && sudo systemctl disable NetworkManager; then
        echo "错误：NetworkManager关闭失败 | Error: Failed to disable NetworkManager"
        exit 1
    fi
fi

# 启用network服务
if ! sudo systemctl enable network --now; then
    echo "错误：network服务启用失败 | Error: Failed to enable network service"
    exit 1
fi

# 二次确认服务状态
echo "正在验证network服务状态... | Verifying network service status..."
if ! systemctl is-active network --quiet; then
    echo "错误：network服务未运行 | Error: network service is not running"
    exit 1
fi

if ! systemctl is-enabled network --quiet; then
    echo "错误：network服务未设置开机启动 | Error: network service not enabled for startup"
    exit 1
fi


# 添加部署模式选择
echo "请选择部署模式 | Please select deployment mode:"
echo "1) All-in-one 模式（快速部署单节点）| All-in-one mode (single node)"
echo "2) 应答文件模式（自定义配置）| Answer file mode (custom configuration)"

while true; do
    read -p "请输入选项编号（1/2）| Enter option number (1/2): " mode
    case $mode in
        1)
            echo "正在执行All-in-one部署... | Starting all-in-one deployment..."
            sudo packstack --allinone
            break
            ;;
        2)
            # 保留原有应答文件流程
            # 验证仓库有效性 | Verify repository validity
            if ! sudo dnf repoquery --disablerepo=* --enablerepo=centos-release-openstack-dalmatian >/dev/null 2>&1; then
                echo "错误：dalmatian仓库不可用 | Error: dalmatian repository unavailable"
                exit 1
            fi

            # 安装仓库 | Install repository
            echo "正在安装仓库... | Installing repository..."
            if ! dnf install -y centos-release-openstack-dalmatian; then
                echo "仓库安装失败，请检查网络连接 | Repository installation failed, check network connection"
                exit 1
            fi

            # 安装基础依赖 | Install base dependencies
            sudo dnf install -y https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/python3-lesscpy-0.14.0-7.el9.noarch.rpm
            sudo dnf install -y https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/fontawesome-fonts-web-4.7.0-13.el9.noarch.rpm
            sudo dnf install -y https://rpmfind.net/linux/centos-stream/9-stream/CRB/x86_64/os/Packages/python3-pyxattr-0.7.2-4.el9.x86_64.rpm

            # 更新系统 | Update system
            sudo dnf update -y

            # 生成应答文件模板 | Generate answer file template
            sudo packstack --gen-answer-file=answer_template.txt

            # 替换默认密码 | Replace default password
            sed -i "s/CONFIG_DEFAULT_PASSWORD=.*/CONFIG_DEFAULT_PASSWORD=mysecretpassword/" answer_template.txt

            # 执行部署命令 | Execute deployment
            sudo packstack --answer-file=answer_template.txt
            break
            ;;
        *)
            echo "无效输入，请重新选择 | Invalid input, please try again"
            ;;
    esac
done

# 后续公共流程
if [ $? -ne 0 ]; then
    echo "部署失败，请检查日志 | Deployment failed, please check logs"
    exit 1
fi

# 部署完成后加载环境变量 | Load environment variables after deployment
# 移动环境变量文件到用户目录
sudo cp /root/keystonerc_admin ~/ && sudo chown ${USER}:${USER} ~/keystonerc_admin

if [ ! -f "${HOME}/keystonerc_admin" ]; then
    echo "错误：环境变量文件复制失败 | Error: Failed to copy environment file"
    exit 1
fi

if [ -f "${HOME}/keystonerc_admin" ]; then
    source ${HOME}/keystonerc_admin
    echo "环境变量加载完成 | Environment variables loaded"
else
    echo "警告：环境变量文件不存在，请检查部署结果 | Warning: Environment file not found, please check deployment"
    exit 1
fi

# 生成新增软件包列表
echo "正在生成新增软件包列表... | Generating new package list..."
rpm -qa | sort > installed_packages_after.log
comm -13 installed_packages_before.log installed_packages_after.log > added_packages.log

# 显示完成信息 | Show completion message
echo "OpenStack部署成功！| OpenStack deployment successful!"