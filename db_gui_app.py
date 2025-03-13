import mysql.connector
import json
import os
from tkinter import Tk, Toplevel, Label, Entry, Button, Frame, LEFT
from tkinter import ttk, messagebox
from cryptography.fernet import Fernet

class DBAccessApp:
    def __init__(self):
        self.root = Tk()
        self.db_config = self._decrypt_config() or {}
        if not self.db_config:
            messagebox.showinfo('提示', '首次使用请先配置数据库连接参数')
        self._setup_ui()

    def _get_db_params(self, entries, encrypt_password=False):
        new_config = {}
        for field, entry in entries.items():
            value = entry.get().strip()
            if field == 'port':
                if not value:
                    value = 3306
                elif not str(value).isdigit():
                    raise ValueError('端口号必须为数字')
                value = int(value)
            if not value and field not in ['password', 'port']:
                raise ValueError(f'{field}不能为空')
            if field == 'password' and encrypt_password:
                value = self._encrypt(str(value).encode('utf-8'))
            new_config[field] = str(value)  # 统一转换为字符串存储
        return new_config

    def _test_connection(self, entries):
        try:
            config = self._get_db_params(entries)
            conn = mysql.connector.connect(
                host=config['host'],
                port=int(config.get('port', 3306)),
                user=config['user'],
                password=config.get('password', ''),
                charset='utf8mb4',
                collation='utf8mb4_general_ci'
            )
            conn.ping(reconnect=True)
            conn.close()
            messagebox.showinfo('成功', '数据库连接测试成功')
        except mysql.connector.Error as err:
            error_msg = f'数据库连接失败: {err.msg} (错误码:{err.errno})'
            messagebox.showerror('错误', error_msg)
        except ValueError as ve:
            messagebox.showerror('错误', f'参数错误: {str(ve)}')
        except Exception as e:
            messagebox.showerror('错误', f'发生未知错误: {str(e)}')

    def _show_config_dialog(self):
        config_window = Toplevel(self.root)
        entries = {}
        fields = ['host', 'port', 'user', 'password']
        
        # 自动填充已有配置
        for i, field in enumerate(fields):
            Label(config_window, text=field).grid(row=i)
            entry = Entry(config_window)
            default_value = str(self.db_config[field]) if self.db_config.get(field) else '3306' if field == 'port' else ''
            entry.insert(0, default_value)
            entry.grid(row=i, column=1)
            entries[field] = entry

        # 添加按钮区
        btn_frame = Frame(config_window)
        btn_frame.grid(row=len(fields), columnspan=2, pady=10, padx=10)
        Button(btn_frame, text="保存配置", command=lambda: self._save_config(entries, config_window)).pack(side=LEFT, padx=5)
        Button(btn_frame, text="测试连接", command=lambda: self._test_connection(entries)).pack(side=LEFT, padx=5)


    def _setup_ui(self):
        self.root.title("数据库管理工具")
        Button(self.root, text="配置数据库", command=self._show_config_dialog).pack()
        self.root.mainloop()

    def _save_config(self, entries, window):
        try:
            self.db_config = self._get_db_params(entries, encrypt_password=True)
            with open('db_config.enc', 'wb') as f:
                encrypted = self._encrypt(json.dumps(self.db_config).encode('utf-8'))
                f.write(encrypted)
            messagebox.showinfo('成功', '配置保存成功')
            window.destroy()
        except Exception as e:
            messagebox.showerror('错误', f'保存失败: {str(e)}')

    def _decrypt_config(self):
        if not os.path.exists('db_config.enc'):
            return None
        try:
            with open('db_config.enc', 'rb') as f:
                encrypted = f.read()
            cipher_suite = Fernet(self._load_or_create_key())
            decrypted = cipher_suite.decrypt(encrypted).decode('utf-8')
            # 删除此处的import语句
            return json.loads(decrypted)
        except (FileNotFoundError, json.JSONDecodeError, ValueError) as e:
            print(f'解密配置失败: {str(e)}')
            return None

    def _encrypt(self, data):
        cipher_suite = Fernet(self._load_or_create_key())
        return cipher_suite.encrypt(data)

    def _load_or_create_key(self):
        try:
            with open('secret.key', 'rb') as key_file:
                return key_file.read()
        except FileNotFoundError:
            key = Fernet.generate_key()
            with open('secret.key', 'wb') as key_file:
                key_file.write(key)
            return key

if __name__ == "__main__":
    app = DBAccessApp()