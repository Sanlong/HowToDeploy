import time
import logging
import paramiko
from functools import wraps

logger = logging.getLogger('error_handler')

class RetryableError(Exception):
    def __init__(self, message, original_exception=None):
        super().__init__(message)
        self.original_exception = original_exception

def retry(max_retries=3, delay=2, exceptions=(Exception,)):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            for attempt in range(1, max_retries+1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    logger.warning(f'[{func.__name__}] 重试 {attempt}/{max_retries} 失败: {str(e)}')
                    if attempt == max_retries:
                        raise RetryableError(f'操作重试{max_retries}次后失败') from e
                    time.sleep(delay)
            return None
        return wrapper
    return decorator

def handle_ssh_errors(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except paramiko.SSHException as e:
            logger.error(f'SSH连接异常: {str(e)}')
            raise
        except TimeoutError as e:
            logger.error(f'连接超时: {str(e)}')
            raise
    return wrapper