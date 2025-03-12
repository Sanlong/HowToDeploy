import csv
import os
import tkinter as tk
from datetime import datetime
from tkinter import filedialog, messagebox

import paramiko

# 获取当前日期
CURRENT_DATE = datetime.now().strftime("%Y%m%d")


def load_device_info(file_path):
    """
    加载设备信息表
    :param file_path: 设备信息表路径
    :return: 设备信息列表
    """
    devices = []
    with open(file_path, mode="r", encoding="utf-8") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            devices.append(row)
    return devices


def ssh_connect_and_fetch_config(device):
    """
    通过SSH连接到设备并获取配置文件
    :param device: 设备信息字典
    """
    try:
        # 创建SSH客户端
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        # 连接到设备
        ssh.connect(
            hostname=device["IP地址"],
            port=22,
            username=device["用户名"],
            password=device["密码"],
            timeout=10
        )

        # 根据厂商执行不同的命令
        vendor = device["厂商"].lower()
        if vendor in ["华为", "h3c", "新华三"]:
            command = "display current-configuration"
        elif vendor == "思科":
            command = "show running-config"
        elif vendor == "锐捷":
            command = "show running-config"
        elif vendor == "juniper":
            command = "show configuration"
        else:
            raise ValueError(f"不支持的厂商: {device['厂商']}")

        # 执行命令并读取输出
        stdin, stdout, stderr = ssh.exec_command(command)
        config_output = stdout.read().decode("utf-8")

        # 关闭连接
        ssh.close()

        # 保存配置文件
        save_config_to_file(device, config_output)

    except Exception as e:
        messagebox.showerror("连接失败", f"设备 {device['设备名称']} 连接失败: {str(e)}")


def save_config_to_file(device, config_output):
    """
    将配置文件保存到本地
    :param device: 设备信息字典
    :param config_output: 配置文件内容
    """
    # 文件名规则：设备名称_日期.txt
    file_name = f"{device['设备名称']}_{CURRENT_DATE}.txt"
    file_path = os.path.join(os.path.dirname(DEVICE_INFO_FILE), file_name)

    # 写入文件
    with open(file_path, mode="w", encoding="utf-8") as file:
        file.write(config_output)

    messagebox.showinfo("保存成功", f"设备 {device['设备名称']} 的配置文件已保存: {file_path}")


def select_file():
    global DEVICE_INFO_FILE
    DEVICE_INFO_FILE = filedialog.askopenfilename(filetypes=[("CSV files", "*.csv")])
    if DEVICE_INFO_FILE:
        messagebox.showinfo("文件选择", f"已选择文件: {DEVICE_INFO_FILE}")
    else:
        messagebox.showwarning("文件选择", "未选择文件")


def main():
    """
    主函数
    """
    # 创建主窗口
    root = tk.Tk()
    root.title("网络设备配置获取工具")

    # 创建按钮
    select_button = tk.Button(root, text="选择设备信息表文件", command=select_file)
    select_button.pack(pady=20)

    # 创建开始按钮
    start_button = tk.Button(root, text="开始获取配置", command=lambda: process_devices())
    start_button.pack(pady=10)

    def process_devices():
        if not DEVICE_INFO_FILE:
            messagebox.showwarning("文件选择", "请先选择设备信息表文件")
            return

        # 加载设备信息表
        devices = load_device_info(DEVICE_INFO_FILE)

        # 遍历设备信息并获取配置文件
        for device in devices:
            print(f"正在处理设备: {device['设备名称']}")
            ssh_connect_and_fetch_config(device)

    # 运行主循环
    root.mainloop()


if __name__ == "__main__":
    main()
