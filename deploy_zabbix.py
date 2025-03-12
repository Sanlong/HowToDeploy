# 在OpenEuler 2203 LTS上部署Zabbix的步骤

# 1. 安装依赖包
import os

os.system('sudo dnf install -y epel-release')
os.system('sudo dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent')

# 2. 安装Zabbix Server及相关组件
os.system('sudo dnf install -y zabbix-server-mysql zabbix-web-mysql zabbix-agent')

# 3. 配置数据库
os.system('sudo mysql_secure_installation')
os.system('sudo mysql -u root -p -e "CREATE DATABASE zabbix character set utf8 collate utf8_bin;"')
os.system('sudo mysql -u root -p -e "CREATE USER \'zabbix\'@\'localhost\' IDENTIFIED BY \'password\';"')
os.system('sudo mysql -u root -p -e "GRANT ALL PRIVILEGES ON zabbix.* TO \'zabbix\'@\'localhost\';"')
os.system('sudo mysql -u root -p -e "FLUSH PRIVILEGES;"')

# 4. 设置Zabbix Server配置文件
with open('/etc/zabbix/zabbix_server.conf', 'a') as f:
    f.write('DBHost=localhost\n')
    f.write('DBName=zabbix\n')
    f.write('DBUser=zabbix\n')
    f.write('DBPassword=password\n')

# 5. 启动相关服务
os.system('sudo systemctl restart zabbix-server zabbix-agent httpd php-fpm')
os.system('sudo systemctl enable zabbix-server zabbix-agent httpd php-fpm')

# 6. 配置Web界面
os.system('sudo firewall-cmd --permanent --add-port=80/tcp')
os.system('sudo firewall-cmd --reload')

# 7. 防火墙设置
os.system('sudo firewall-cmd --permanent --add-port=10050/tcp')
os.system('sudo firewall-cmd --permanent --add-port=10051/tcp')
os.system('sudo firewall-cmd --reload')
