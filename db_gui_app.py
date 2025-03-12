#!/usr/bin/env python3

import tkinter as tk
from tkinter import simpledialog
from tkinter import ttk, messagebox

import mysql.connector
from cryptography.fernet import Fernet
from sshtunnel import SSHTunnelForwarder


class DBAccessApp:
    def __init__(self, master):
        self.master = master
        master.title("数据库管理工具 v1.0")

        # 加密配置（移除默认密码加密，等待用户配置）
        self.key: bytes = Fernet.generate_key()
        self.cipher_suite: Fernet = Fernet(self.key)
        self.db_config: dict = {
            'host': 'localhost',
            'user': 'root',  # 默认用户名从 'admin' 更改为 'root'
            'port': 3306,
            'password': b'',  # 初始化为空
            'database': 'mysql',  # 默认数据库从 'zabbix' 更改为 'mysql'
            'use_ssh': False,  # 新增：是否使用SSH连接
            'ssh_host': None,  # 新增SSH配置
            'ssh_port': 22,
            'ssh_user': None,
            'ssh_password': None
        }
        self.conn = None
        self.ssh_tunnel = None  # 新增SSH隧道对象
        self._create_widgets()

    def _create_widgets(self):
        """创建界面组件（移除状态指示器初始化）"""
        btn_frame = ttk.Frame(self.master)
        btn_frame.pack(pady=10)

        # 新增状态指示器（灰色初始状态）
        self.status_canvas = tk.Canvas(btn_frame, width=20, height=20)
        self.status_canvas.grid(row=0, column=0, padx=5)
        self.status_indicator = self.status_canvas.create_oval(2, 2, 18, 18, fill='gray')  # 初始化为灰色

        # 操作按钮
        button_config = {
            "连接数据库": self.connect_to_db,
            "配置数据库": self.configure_db,
            "新增记录": self.add_record,
            "删除记录": self.delete_record,
            "刷新数据": self.refresh_data
        }

        for idx, (text, command) in enumerate(button_config.items(), start=1):
            button = ttk.Button(btn_frame, text=text, command=command)
            button.grid(row=0, column=idx, padx=5, pady=5, sticky="ew")  # 增加 pady 以增加按钮之间的垂直间距

        # 数据表格
        self.tree = ttk.Treeview(self.master)
        self.tree.pack(pady=20, padx=10, fill="both", expand=True)
        self.tree['columns'] = ('id', 'username', 'role')
        self.tree.heading('id', text='ID')
        self.tree.heading('username', text='用户名')
        self.tree.heading('role', text='角色')

    # --------------------------
    # 新增错误建议方法
    # --------------------------
    # 数据库连接管理
    # --------------------------
    def connect_to_db(self):
        """执行数据库连接（支持直接连接和SSH隧道连接）"""
        try:
            connection_params = {
                'host': self.db_config['host'],
                'port': self.db_config['port'],
                'user': self.db_config['user'],
                'password': self.db_config['password'].decode() if self.db_config['password'] else ''
            }

            # 如果使用SSH连接
            if self.db_config['use_ssh']:
                if not all([self.db_config['ssh_host'], self.db_config['ssh_user'], self.db_config['ssh_password']]):
                    raise ValueError("请先配置完整的SSH连接信息")

                # 建立SSH隧道
                self.ssh_tunnel = SSHTunnelForwarder(
                    (self.db_config['ssh_host'], self.db_config['ssh_port']),
                    ssh_username=self.db_config['ssh_user'],
                    ssh_password=self.db_config['ssh_password'].decode(),
                    remote_bind_address=(self.db_config['host'], self.db_config['port'])
                )
                self.ssh_tunnel.start()
                connection_params['host'] = '127.0.0.1'
                connection_params['port'] = self.ssh_tunnel.local_bind_port

            # 关闭现有连接（如果存在）
            if self.conn and self.conn.is_connected():
                self.conn.close()

            # 建立新连接
            self.conn = mysql.connector.connect(**connection_params)

            # 获取可用数据库列表
            cursor = self.conn.cursor()
            cursor.execute("SHOW DATABASES")
            databases = [db[0] for db in cursor.fetchall()]
            cursor.close()

            # 让用户选择数据库
            selected_db = simpledialog.askstring("选择数据库", "请选择一个数据库：",
                                                 initialvalue=self.db_config.get('database', ''),
                                                 parent=self.master)

            if selected_db and selected_db in databases:
                self.db_config['database'] = selected_db
                # 重新连接并选择数据库
                self.conn.database = selected_db
                self._update_connection_status(True)
                messagebox.showinfo("连接成功", f"已成功连接到数据库：{selected_db}")
            else:
                messagebox.showerror("选择错误", "无效的数据库选择")
                self.conn.close()
                self.conn = None
                self._update_connection_status(False)

        except Exception as e:
            # 检查错误代码1273
            if isinstance(e, mysql.connector.Error) and e.errno == 1273:
                error_msg = f"错误代码1273: 参数类型不匹配或参数数量不正确\n建议操作：\n1. 检查输入参数\n2. 验证SQL语句"
                messagebox.showerror("连接失败", error_msg)
            else:
                messagebox.showerror("连接失败", str(e))
            self._update_connection_status(False)
            if self.ssh_tunnel:
                self.ssh_tunnel.stop()

    # --------------------------
    # 数据库配置管理
    # --------------------------
    # 修改数据库配置对话框以包含SSH配置
    def configure_db(self):
        """数据库配置对话框"""
        config_win = tk.Toplevel()
        config_win.title("数据库配置")

        # 新增：是否使用SSH连接的复选框
        use_ssh = tk.BooleanVar(value=self.db_config['use_ssh'])
        ttk.Checkbutton(config_win, text="使用SSH连接", variable=use_ssh).grid(row=0, columnspan=2, pady=5)

        # 输入字段
        fields = [
            ('host', '主机:', 1),
            ('port', '端口:', 2),
            ('user', '用户名:', 3),
            ('password', '密码:', 4),
            ('ssh_host', 'SSH主机:', 5),
            ('ssh_port', 'SSH端口:', 6),
            ('ssh_user', 'SSH用户名:', 7),
            ('ssh_password', 'SSH密码:', 8)
        ]
        entries = {}
        for idx, (field, label, row) in enumerate(fields):
            ttk.Label(config_win, text=label).grid(row=row, column=0, sticky="w")
            entry = ttk.Entry(config_win, show="*" if 'password' in field else "")
            entry.insert(0, str(self.db_config[field]) if field != 'password' and field != 'ssh_password' else "")
            entry.grid(row=row, column=1, sticky="ew", padx=5, pady=5)  # 增加 sticky="ew" 和 padx, pady
            entries[field] = entry

        # 更新保存配置逻辑
        def save_config():
            try:
                port_input = entries['port'].get().strip()
                if not port_input:
                    raise ValueError("端口号不能为空")
                if not port_input.isdigit():
                    raise ValueError("端口号必须为纯数字")

                new_config = {
                    'host': entries['host'].get(),
                    'port': int(port_input),
                    'user': entries['user'].get(),
                    'password': self._encrypt(entries['password'].get()),
                    'use_ssh': use_ssh.get(),
                    'ssh_host': entries['ssh_host'].get(),
                    'ssh_port': int(entries['ssh_port'].get()),
                    'ssh_user': entries['ssh_user'].get(),
                    'ssh_password': self._encrypt(entries['ssh_password'].get())
                }
                self.db_config.update(new_config)

                if self.conn and self.conn.is_connected():
                    self.conn.close()
                self.conn = None
                self._update_connection_status(False)

                messagebox.showinfo("配置成功", "数据库配置已保存")
                config_win.destroy()

            except ValueError as e:
                error_types = {
                    "不能为空": "端口号不能为空",
                    "必须为纯数字": "端口号必须为0-9的数字字符"
                }
                error_msg = next((v for k, v in error_types.items() if k in str(e)), "无效端口格式")
                messagebox.showerror("输入错误", error_msg)
            except Exception as e:
                messagebox.showerror("保存失败", str(e))

        # 再定义测试连接方法
        def test_connection():
            """测试数据库连接"""
            try:
                test_params = {
                    'host': entries['host'].get(),
                    'port': int(entries['port'].get().strip()),
                    'user': entries['user'].get(),
                    'password': entries['password'].get(),
                    'database': self.db_config['database']
                }

                temp_conn = mysql.connector.connect(**test_params)
                if temp_conn.is_connected():
                    messagebox.showinfo("连接测试", "数据库连接成功！")
                temp_conn.close()

            except ValueError:
                messagebox.showerror("测试失败", "端口号必须为有效数字")
            except mysql.connector.Error as e:
                # 替换错误建议调用
                error_msg = f"{str(e)}\n\n建议操作：\n1. 检查输入参数\n2. 验证访问权限\n3. 确认服务状态"
                messagebox.showerror("连接失败", error_msg)
            except Exception as e:
                messagebox.showerror("测试异常", f"未知错误: {str(e)}")

        # 最后创建按钮
        btn_frame = ttk.Frame(config_win)
        btn_frame.grid(row=len(fields) + 1, columnspan=2, pady=10, sticky="ew")  # 增加 sticky="ew"
        ttk.Button(btn_frame, text="测试连接", command=test_connection).grid(row=0, column=0, padx=5)
        ttk.Button(btn_frame, text="保存", command=save_config).grid(row=0, column=1, padx=5)

    # --------------------------
    # 数据操作功能
    # --------------------------
    def refresh_data(self):
        """刷新表格数据"""
        if not self._check_connection():
            return

        try:
            # 确保连接不为 None
            if self.conn is None:
                raise ConnectionError("数据库连接不可用")

            # 显式指定游标类型
            try:
                cursor = self.conn.cursor(dictionary=True)
            except Exception as e:
                raise Exception(f"获取游标失败: {str(e)}")
            cursor.execute("SELECT id, username, role FROM users WHERE is_active = 1")

        except ConnectionError as ce:
            messagebox.showerror("连接异常", str(ce))
            self._update_connection_status(False)
        except Exception as e:
            messagebox.showerror("刷新失败", str(e))

    def add_record(self):
        """新增用户记录"""
        if not self._check_connection():
            return

        add_win = tk.Toplevel()
        add_win.title("新增用户")

        # 输入字段
        ttk.Label(add_win, text="用户名:").grid(row=0, column=0)
        username = ttk.Entry(add_win)
        username.grid(row=0, column=1)

        ttk.Label(add_win, text="角色:").grid(row=1, column=0)
        role = ttk.Combobox(add_win, values=['admin', 'user', 'auditor'])
        role.grid(row=1, column=1)

        def submit():
            try:
                # 添加连接检查
                if not (self.conn and self.conn.is_connected()):
                    raise ConnectionError("数据库连接不可用")

                cursor = self.conn.cursor()
                cursor.execute(
                    "INSERT INTO users (username, role) VALUES (%s, %s)",
                    (username.get(), role.get())
                )
                self.conn.commit()

                self.refresh_data()

                add_win.destroy()

                messagebox.showinfo("成功", "记录添加成功")

            except Exception as e:
                messagebox.showerror("提交错误", str(e))

        ttk.Button(add_win, text="提交", command=submit).grid(row=2, columnspan=2)

    def delete_record(self):
        """删除选中记录"""
        if not self._check_selection() or not self._check_connection():
            return

        try:
            # 在获取cursor前添加连接检查
            if not (self.conn and self.conn.is_connected()):
                raise ConnectionError("数据库连接不可用")

            selected_item = self.tree.selection()[0]

            cursor = self.conn.cursor()

            cursor.execute(
                "DELETE FROM users WHERE id = %s",
                (self.tree.item(selected_item)['values'][0],)
            )

            # 提交前再次验证连接状态
            if self.conn.is_connected():
                self.conn.commit()

                self.refresh_data()

                messagebox.showinfo("成功", "记录删除成功")

            else:

                messagebox.showerror("连接错误", "操作期间连接已断开")

        except ConnectionError as ce:
            messagebox.showerror("连接异常", str(ce))

            self._update_connection_status(False)

        except AttributeError as ae:
            messagebox.showerror("操作失败", f"无效的数据库连接: {str(ae)}")

        except Exception as e:
            messagebox.showerror("删除失败", str(e))

    # --------------------------
    # 辅助方法
    # --------------------------
    def _update_connection_status(self, is_connected):
        """更新连接状态指示"""
        color = 'green' if is_connected else 'red'
        self.status_canvas.itemconfig(self.status_indicator, fill=color)

    def _encrypt(self, text: str) -> bytes:
        """加密敏感信息"""
        return self.cipher_suite.encrypt(text.encode())

    def _check_connection(self) -> bool:
        """验证数据库连接状态"""
        if self.conn and self.conn.is_connected():
            return True

        self._update_connection_status(False)

        messagebox.showerror("连接错误", "请先连接数据库")

        return False

    def _check_selection(self) -> bool:
        """验证表格选择状态"""
        if self.tree.selection():
            return True

        messagebox.showwarning("选择错误", "请先选择要操作的记录")

        return False


if __name__ == "__main__":
    root = tk.Tk()

    app = DBAccessApp(root)

    root.mainloop()
