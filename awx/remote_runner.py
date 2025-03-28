# 导入所需模块
import argparse
import base64
import getpass
import hashlib
import logging
import os
import sys
from pathlib import Path
import yaml  # 添加缺失的导入

# 标准库导入结束

import paramiko

# 第三方库导入结束

# 配置 logger
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)  # 确保 logger 在全局范围定义


class RemoteRunner:
    def __init__(self, host, user, key_path, logger):
        self.host = host
        self.user = user
        self.key_path = key_path
        self.client = None
        self.logger = logger

    def connect(self):
        """建立 SSH 连接"""
        try:
            self.client = paramiko.SSHClient()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.client.connect(
                hostname=self.host,
                username=self.user,
                key_filename=self.key_path,
                timeout=10
            )  # 修复缺失的右括号
            self.logger.info(f"成功连接到主机: {self.host}")
        except paramiko.AuthenticationException:
            self.logger.error("认证失败，请检查用户名或密钥文件")
            sys.exit(1)
        except paramiko.SSHException as e:
            self.logger.error(f"SSH 连接错误: {e}")
            sys.exit(1)
        except Exception as e:
            self.logger.error(f"未知错误导致连接失败: {e}")
            sys.exit(1)

    def execute_command(self, command):
        """执行远程命令"""
        if not self.client:
            self.logger.error("未建立连接，请先调用 connect 方法")
            return None

        try:
            stdin, stdout, stderr = self.client.exec_command(command)
            output = stdout.read().decode('utf-8').strip()  # 去除多余空白字符
            error = stderr.read().decode('utf-8').strip()   # 去除多余空白字符
            if error:
                self.logger.error(f"命令执行出错: {error}")
            else:
                self.logger.info(f"命令输出: {output}")
            return output
        except paramiko.SSHException as e:
            self.logger.error(f"SSH 命令执行失败: {e}")
            return None
        except Exception as e:
            self.logger.error(f"未知错误导致命令执行失败: {e}")
            return None

    def close(self):
        """关闭 SSH 连接"""
        if self.client:
            self.client.close()
            self.logger.info("SSH 连接已关闭")


def load_config(config_path):
    """加载配置文件"""
    try:
        with open(config_path, 'r', encoding='utf-8') as file:
            config = yaml.safe_load(file)
            if not isinstance(config, dict):
                logger.error("配置文件内容格式不正确，应为键值对形式")
                sys.exit(1)
            return config
    except FileNotFoundError:
        logger.error(f"配置文件未找到: {config_path}")
        sys.exit(1)
    except yaml.YAMLError as e:
        logger.error(f"配置文件解析错误: {e}")
        sys.exit(1)


if __name__ == "__main__":
    # 示例用法
    config_path = Path(__file__).parent / "config.yaml"
    logger.info(f"尝试加载配置文件: {config_path}")
    config = load_config(config_path)
    runner = RemoteRunner(
        host=config.get('host'),
        user=config.get('user'),  # 添加缺失的 user 参数
        key_path=config.get('key_path'),
        logger=logger
    )
    runner.connect()
    runner.execute_command("ls -l")
    runner.close()