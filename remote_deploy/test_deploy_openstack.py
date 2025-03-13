import unittest
from unittest.mock import patch, MagicMock
import logging
from remote_deploy.deploy_openstack import OpenStackDeployer
import os
import subprocess
from parameterized import parameterized

class TestOpenStackDeployment(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        # 禁用全局日志输出
        logging.disable(logging.CRITICAL)

    def setUp(self):
        self.test_config = os.path.join(os.path.dirname(__file__), 'config_test.json')
        self.deployer = OpenStackDeployer(self.test_config)
        
        # 模拟SSH连接
        self.deployer.ssh = MagicMock()
        
    def test_environment_validation(self):
        """测试主控机环境检查逻辑"""
        # 模拟成功的环境检查
        with patch('subprocess.run') as mock_run:
            mock_run.return_value.returncode = 0
            self.deployer.check_master_environment()
            
        # 模拟失败的场景
        with patch('subprocess.run') as mock_run:
            mock_run.return_value.returncode = 1
            with self.assertRaises(RuntimeError):
                self.deployer.check_master_environment()

    @patch('datetime.datetime')
    def test_answer_file_generation(self, mock_dt):
        """测试应答文件生成功能"""
        # 固定时间戳
        mock_dt.now.return_value.strftime.return_value = '20231122093000'
        
        with patch('subprocess.run') as mock_run, \
             patch('builtins.open', unittest.mock.mock_open()) as mock_file:
            
            # 执行生成应答文件
            self.deployer.generate_answer_file()
            
            # 验证文件名格式
            mock_file.assert_called_with('/tmp/packstack_answer_test_20231122093000', 'r+')
            
            # 验证配置替换
            file_handle = mock_file()
            written_content = file_handle.write.call_args[0][0]
            self.assertIn('CONFIG_DEFAULT_PASSWORD=test_password', written_content)
            self.assertIn('CONFIG_CONTROLLER_HOST=192.168.1.100', written_content)

    @patch('subprocess.run')
    def test_deployment_workflow(self, mock_run):
        """测试完整部署流程"""
        # 生成默认应答文件
        output_path = '/tmp/packstack_answer_test_20231122093000'
        gen_cmd = f"packstack --gen-answer-file={output_path}"
        result = subprocess.run(
            gen_cmd.split(),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        if result.returncode != 0:
            raise RuntimeError(f'生成默认应答文件失败: {result.stderr.decode()}')
        mock_run.return_value = MagicMock(returncode=0, stderr=subprocess.PIPE)
        mock_run.return_value.stderr.decode.return_value = ''
        result = self.deployer.execute_commands()
        self.assertTrue(result)

        # 模拟成功部署
        mock_run.return_value = MagicMock(
            returncode=0,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )
        mock_run.return_value.stdout.decode.return_value = 'Success'
        mock_run.return_value.stderr.decode.return_value = ''
        result = self.deployer.execute_commands()
        self.assertTrue(result)

    def test_pre_deployment_checks(self):
        # 完整模拟SSH通道状态
        mock_stderr = MagicMock()
        mock_stderr.channel = MagicMock()
        mock_stderr.channel.recv_exit_status.return_value = 0
        
        # 成功场景模拟
        self.deployer.ssh.exec_command.side_effect = [
            (None, None, mock_stderr),
            (None, None, mock_stderr),
            (None, None, mock_stderr),
            (None, None, mock_stderr)
        ]
        self.deployer.pre_deployment_checks()

        # 失败场景模拟
        mock_stderr_fail = MagicMock()
        mock_stderr_fail.channel = MagicMock()
        mock_stderr_fail.channel.recv_exit_status.return_value = 1
        self.deployer.ssh.exec_command.side_effect = [
            (None, None, mock_stderr_fail)
        ]
        with self.assertRaises(RuntimeError):
            self.deployer.pre_deployment_checks()

if __name__ == '__main__':
    unittest.main()