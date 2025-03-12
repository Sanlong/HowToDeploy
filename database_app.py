import json  # 添加 json 模块导入
import os  # 添加 os 模块导入
from tkinter import Canvas  # 添加 Canvas 导入
from tkinter import messagebox, Tk, Entry, Button
from tkinter.ttk import Combobox
from typing import Optional, Tuple, List, Dict, Any

import mysql.connector


class DatabaseApp:
    # 支持的字符集列表
    SUPPORTED_CHARSETS: List[str] = ['utf8mb4', 'latin1', 'utf8', 'ascii', 'general']
    # 数据库连接配置模板
    CONNECTION_CONFIG_TEMPLATE: Dict[str, Any] = {
        'host': '',
        'user': '',
        'password': '',
        'charset': ''
    }
    # 保存连接参数的文件路径
    CONFIG_FILE_PATH = "db_config.json"

    def __init__(self, host_entry: Entry, user_entry: Entry, password_entry: Entry, db_combobox: Combobox, root: Tk):
        # 初始化输入组件
        self.host_entry = host_entry
        self.user_entry = user_entry
        self.password_entry = password_entry
        self.db_combobox = db_combobox
        self.root = root  # 初始化 root 属性
        # 绑定下拉列表的点击事件
        self.db_combobox.bind("<Button-1>", self.on_combobox_click)
        # 加载保存的连接参数
        self.load_connection_params()

    def load_connection_params(self):
        """加载保存的连接参数"""
        if os.path.exists(self.CONFIG_FILE_PATH):
            try:
                with open(self.CONFIG_FILE_PATH, "r") as f:
                    config = json.load(f)
                    self.host_entry.insert(0, config.get("host", ""))
                    self.user_entry.insert(0, config.get("user", ""))
                    self.password_entry.insert(0, config.get("password", ""))
            except Exception as e:
                messagebox.showerror("Error", f"Failed to load saved connection parameters: {str(e)}")

    def save_connection_params(self):
        """保存连接参数到文件"""
        connection_params = self._get_connection_params()
        if not connection_params:
            return

        host, user, password = connection_params
        config = {
            "host": host,
            "user": user,
            "password": password
        }
        try:
            with open(self.CONFIG_FILE_PATH, "w") as f:
                json.dump(config, f)
        except Exception as e:
            messagebox.showerror("Error", f"Failed to save connection parameters: {str(e)}")

    def on_combobox_click(self, event):
        """下拉列表点击事件处理函数"""
        self.test_connection()

    def _get_connection_params(self) -> Optional[Tuple[str, str, str]]:
        """获取并验证连接参数"""
        host = self.host_entry.get().strip()
        user = self.user_entry.get().strip()
        password = self.password_entry.get().strip()

        if not all([host, user, password]):
            messagebox.showerror("Error", "Host, User, and Password cannot be empty!")
            return None

        return host, user, password

    def _try_connect_with_charset(self, host: str, user: str, password: str, charset: str) -> Tuple[
        Optional[mysql.connector.MySQLConnection], Optional[str]]:
        """尝试使用指定字符集连接数据库"""
        try:
            config = self.CONNECTION_CONFIG_TEMPLATE.copy()
            config.update({
                'host': host,
                'user': user,
                'password': password,
                'charset': charset
            })
            conn = mysql.connector.connect(**config)
            return conn, None
        except mysql.connector.Error as e:
            return None, f"Failed with charset {charset}: {str(e)}"

    def _handle_connection_success(self, conn: mysql.connector.MySQLConnection, charset: str) -> bool:
        """处理成功连接后的操作"""
        try:
            with conn.cursor() as cursor:
                cursor.execute("SHOW DATABASES;")
                databases: List[str] = [row[0] for row in cursor.fetchall()]

                self.db_combobox["values"] = databases
                if databases:
                    self.db_combobox.current(0)
                else:
                    messagebox.showwarning("Warning", "No databases found on the server!")

                return True
        except mysql.connector.Error as e:
            messagebox.showerror("Error", f"Database query failed: {str(e)}")
            return False

    def test_connection(self) -> None:
        """测试数据库连接并加载数据库列表"""
        connection_params = self._get_connection_params()
        if not connection_params:
            return

        host, user, password = connection_params
        errors = []

        for charset in self.SUPPORTED_CHARSETS:
            conn, error = self._try_connect_with_charset(host, user, password, charset)
            if error:
                errors.append(error)
                continue

            try:
                if self._handle_connection_success(conn, charset):
                    return
            finally:
                conn.close()

        # 所有字符集尝试失败后，统一弹出错误提示窗口
        if errors:
            messagebox.showerror("Error",
                                 "Failed to connect to the database server with all available charsets!\n\n" + "\n".join(
                                     errors))

    def _save_and_exit(self):
        """保存连接信息并退出到增删改查操作页面"""
        self.save_connection_params()  # 保存连接参数
        self.root.destroy()  # 关闭当前窗口
        # 打开增删改查操作页面
        # 假设增删改查操作页面的类为DatabaseCRUDApp
        crud_app = DatabaseCRUDApp()
        crud_app.mainloop()


class DatabaseCRUDApp:
    """数据库增删改查操作页面"""

    def __init__(self):
        self.root = Tk()
        self.root.title("Database CRUD Operations")
        self.root.geometry("600x400")  # 设置窗口大小

        # 添加圆形灯显示数据库连接状态
        self.canvas = Canvas(self.root, width=50, height=50)
        self.canvas.pack()
        self.status_light = self.canvas.create_oval(10, 10, 40, 40, fill="red")  # 初始状态为红色

        # 在这里添加增删改查操作页面的UI组件
        # 例如：表格、按钮、输入框等

    def update_status_light(self, status: str):
        """根据连接状态更新灯的颜色"""
        if status == "connected":
            self.canvas.itemconfig(self.status_light, fill="green")  # 连接正常时为绿色
        elif status == "disconnected":
            self.canvas.itemconfig(self.status_light, fill="red")  # 断开连接时为红色
        elif status == "connecting":
            self.canvas.itemconfig(self.status_light, fill="yellow")  # 连接中时为黄色

    def mainloop(self):
        """启动增删改查操作页面的主事件循环"""
        self.root.mainloop()


# 添加主程序入口和事件循环
if __name__ == "__main__":
    root = Tk()
    root.title("Database Connection Test")

    # 设置窗口大小
    root.geometry("400x300")  # 设置窗口宽度为400像素，高度为300像素

    # 创建输入框和下拉框
    host_entry = Entry(root)
    host_entry.pack()

    user_entry = Entry(root)
    user_entry.pack()

    password_entry = Entry(root, show="*")
    password_entry.pack()

    db_combobox = Combobox(root)
    db_combobox.pack()

    # 创建按钮并绑定测试连接功能
    app = DatabaseApp(host_entry, user_entry, password_entry, db_combobox, root)  # 传递 root 参数
    Button(root, text="测试连接", command=app.test_connection).pack()

    # 创建保存按钮并绑定保存并退出功能
    Button(root, text="保存", command=app._save_and_exit).pack()

    # 启动主事件循环
    root.mainloop()
