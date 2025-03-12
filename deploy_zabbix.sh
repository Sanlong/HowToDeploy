#!/bin/bash

# 检查Ansible是否已安装
if ! command -v ansible &> /dev/null
then
    echo "Ansible 未安装，请先安装 Ansible"
    exit 1
fi

# 服务器信息表路径
SERVER_INFO_FILE="servers.csv"

# 检查服务器信息表是否存在
if [ ! -f "$SERVER_INFO_FILE" ]; then
    echo "服务器信息表 $SERVER_INFO_FILE 不存在"
    exit 1
fi

# 生成Ansible inventory文件
INVENTORY_FILE="inventory.ini"
echo "[zabbix_clients]" > $INVENTORY_FILE

while IFS=, read -r ip username password
do
    echo "$ip ansible_user=$username ansible_password=$password" >> $INVENTORY_FILE
done < <(tail -n +2 "$SERVER_INFO_FILE")

# 生成Ansible Playbook文件
PLAYBOOK_FILE="deploy_zabbix.yml"
cat <<EOF > $PLAYBOOK_FILE
---
- name: Deploy Zabbix Agent
  hosts: zabbix_clients
  become: yes
  tasks:
    - name: Ensure Zabbix repository is present
      yum_repository:
        name: zabbix
        description: Zabbix Official Repository
        baseurl: http://repo.zabbix.com/zabbix/6.0/rhel/8/x86_64/
        gpgcheck: yes
        enabled: yes
        gpgkey: http://repo.zabbix.com/RPM-GPG-KEY-ZABBIX

    - name: Install Zabbix Agent
      yum:
        name: zabbix-agent
        state: present

    - name: Configure Zabbix Agent
      template:
        src: zabbix_agentd.conf.j2
        dest: /etc/zabbix/zabbix_agentd.conf
      notify:
        - restart zabbix-agent

    - name: Start and enable Zabbix Agent
      service:
        name: zabbix-agent
        state: started
        enabled: yes

  handlers:
    - name: restart zabbix-agent
      service:
        name: zabbix-agent
        state: restarted
EOF

# 运行Ansible Playbook
ansible-playbook -i $INVENTORY_FILE $PLAYBOOK_FILE