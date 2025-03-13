是的，你可以在使用 **Packstack** 部署 OpenStack 时直接设置 Neutron 后端为 **ML2 + Open vSwitch**，并启用 **VPNaaS**。Packstack 通过回答文件（`answer-file`）来配置部署选项。以下是具体步骤：

---

### 1. **生成默认的 Answer 文件**
如果你还没有生成 Answer 文件，可以使用以下命令生成：
```bash
packstack --gen-answer-file=answer.txt
```

---

### 2. **修改 Answer 文件**
编辑生成的 `answer.txt` 文件，找到并修改以下参数：

#### 设置 Neutron 后端为 ML2 + Open vSwitch
1. 找到 `CONFIG_NEUTRON_ML2_TYPE_DRIVERS` 参数，设置为 `vxlan` 或 `vlan`：
   ```ini
   CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan
   ```

2. 找到 `CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS` 参数，设置为 `openvswitch`：
   ```ini
   CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS=openvswitch
   ```

3. 找到 `CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS` 参数，设置物理网络映射（例如 `physnet1:br-ex`）：
   ```ini
   CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-ex
   ```

4. 找到 `CONFIG_NEUTRON_OVS_BRIDGE_IFACES` 参数，设置外部网络接口（例如 `br-ex:eth0`）：
   ```ini
   CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eth0
   ```

#### 启用 VPNaaS
1. 找到 `CONFIG_NEUTRON_VPNAAS` 参数，设置为 `y`：
   ```ini
   CONFIG_NEUTRON_VPNAAS=y
   ```

2. 找到 `CONFIG_NEUTRON_L2_AGENT` 参数，设置为 `openvswitch`：
   ```ini
   CONFIG_NEUTRON_L2_AGENT=openvswitch
   ```

---

### 3. **运行 Packstack 部署**
使用修改后的 Answer 文件运行 Packstack 部署：
```bash
packstack --answer-file=answer.txt
```

---

### 4. **验证部署**
1. 检查 Neutron 后端是否配置正确：
   ```bash
   openstack network agent list
   ```
   - 确认 `Open vSwitch agent` 已启动并运行。

2. 检查 VPNaaS 是否启用：
   ```bash
   openstack vpn service list
   ```

---

### 5. **示例 Answer 文件片段**
以下是相关配置的示例片段：
```ini
# Neutron ML2 配置
CONFIG_NEUTRON_ML2_TYPE_DRIVERS=vxlan
CONFIG_NEUTRON_ML2_MECHANISM_DRIVERS=openvswitch

# Open vSwitch 配置
CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS=physnet1:br-ex
CONFIG_NEUTRON_OVS_BRIDGE_IFACES=br-ex:eth0

# VPNaaS 配置
CONFIG_NEUTRON_VPNAAS=y
CONFIG_NEUTRON_L2_AGENT=openvswitch
```

---

### 6. **注意事项**
- **网络接口名称**：确保 `CONFIG_NEUTRON_OVS_BRIDGE_IFACES` 中的接口名称（如 `eth0`）与你的实际接口名称一致。
- **物理网络映射**：`CONFIG_NEUTRON_OVS_BRIDGE_MAPPINGS` 中的 `physnet1` 需要与你的网络拓扑匹配。
- **VPNaaS 依赖**：VPNaaS 需要额外的插件（如 `openswan` 或 `strongswan`），确保这些插件已安装并配置。

---

通过以上步骤，你可以在 Packstack 部署时直接设置 Neutron 后端为 ML2 + Open vSwitch，并启用 VPNaaS。如果有其他问题，请随时告诉我！