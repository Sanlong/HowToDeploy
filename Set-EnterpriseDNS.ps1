# 企业级DNS统一配置脚本
# 版本 1.0

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({ 
        $_ -match '^(\d{1,3}\.){3}\d{1,3}$' -or $_ -match '^([0-9a-fA-F]{0,4}:){2,7}[0-9a-fA-F]{0,4}$'
    })]
    [string[]]$DNSServers,

    [Parameter()]
    [ValidateRange(1, 3600)]
    [int]$TimeoutSec = 60,

    [Parameter()]
    [string]$SearchBase = 'OU=Workstations,DC=contoso,DC=com'
)

begin {
    # 检查Active Directory模块
    if (-not (Get-Module -Name ActiveDirectory)) {
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
        }
        catch {
            Write-Error "需要Active Directory模块支持，请安装RSAT工具"
            exit 1
        }
    }

    # 初始化统计信息
    $script:TotalComputers = 0
    $script:SuccessCount = 0
    $script:FailedComputers = @()
    $script:StartTime = Get-Date
    $LogFile = "DNS_Config_Log_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

    # 验证域管理员权限
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    if (-not (Get-ADGroupMember 'Domain Admins' -Recursive | Where-Object {$_.SamAccountName -eq $currentUser.Split('\')[1]})) {
        Write-Error "必须使用域管理员权限运行此脚本"
        exit 1
    }

    # 新增网络连通性检查函数
    function Test-EnterpriseConnection {
        param($Computer, $Retries=3, $Timeout=2000)
        $attempt = 0
        do {
            if (Test-Connection $Computer -Count 1 -TimeoutMilliseconds $Timeout -Quiet) {
                return $true
            }
            Start-Sleep -Milliseconds 500
        } while ($attempt++ -lt $Retries)
        return $false
    }
}

process {
    try {
        # 获取域内计算机列表
        $Computers = Get-ADComputer -Filter * -SearchBase $SearchBase | 
                    Where-Object { $_.Enabled -eq $true } | 
                    Select-Object -ExpandProperty DNSHostName

        $script:TotalComputers = $Computers.Count

        # 创建进度条参数
        $ProgressParams = @{
            Activity = "正在配置企业DNS设置"
            Status = "已完成 0/$($script:TotalComputers)"
            PercentComplete = 0
        }

        # 并行处理所有计算机
        $Computers | ForEach-Object -ThrottleLimit 50 -Parallel {
            $Computer = $_
            $Result = [PSCustomObject]@{
                ComputerName = $Computer
                Status = $null
                Error = $null
                Timestamp = Get-Date
            }

            try {
                # 远程执行DNS配置
                $SessionParams = @{
                    ComputerName  = $Computer
                    ErrorAction   = 'Stop'
                    SessionOption = New-PSSessionOption -IdleTimeout ($using:TimeoutSec * 1000)
                }

                Invoke-Command @SessionParams -ScriptBlock {
                    param($Servers)
                    $Adapter = Get-NetAdapter -Physical | 
                              Where-Object Status -eq 'Up' | 
                              Select-Object -First 1

                    if (-not $Adapter) {
                        throw "找不到活动的物理网络适配器"
                    }

                    Set-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex `
                                              -ServerAddresses $Servers `
                                              -Validate -ErrorAction Stop

                    ipconfig /flushdns | Out-Null
                } -ArgumentList $DNSServers

                $Result.Status = 'Success'
            }
            catch {
                $Result.Status = 'Failed'
                $Result.Error = $_.Exception.Message
                $using:script:FailedComputers += $Computer
            }
            finally {
                # 更新进度并记录日志
                $Result | Export-Csv -Path $using:LogFile -Append -NoTypeInformation
                [System.Threading.Interlocked]::Increment([ref]$using:SuccessCount) | Out-Null
                $using:ProgressParams.PercentComplete = [math]::Round(($using:SuccessCount / $using:TotalComputers) * 100)
                $using:ProgressParams.Status = "已完成 $($using:SuccessCount)/$($using:TotalComputers)"
                Write-Progress @using:ProgressParams
            }
        }
    }
    catch {
        Write-Error "脚本执行过程中发生错误: $_"
        exit 1
    }
    finally {
        Write-Progress -Activity $ProgressParams.Activity -Completed
    }
}

end {
    # 生成统计报告
    $TimeSpan = New-TimeSpan -Start $script:StartTime -End (Get-Date)
    $Report = @"
======================== DNS配置作业报告 ========================
开始时间:        $($script:StartTime)
总计算机数:      $($script:TotalComputers)
成功配置数:      $($script:SuccessCount)
失败数:          $($script:TotalComputers - $script:SuccessCount)
总耗时:          $($TimeSpan.ToString('hh\:mm\:ss'))
日志文件:        $LogFile

失败计算机列表:
$($script:FailedComputers -join "`r`n")

操作说明:
1. 使用域管理员权限运行脚本
2. 示例命令: .\Set-EnterpriseDNS.ps1 -DNSServers '192.168.1.10','192.168.1.20'
3. 查看日志文件获取详细执行结果
"@
    $Report | Out-File "DNS_Config_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt" -Encoding UTF8 -Force
    Write-Host $Report -ForegroundColor Cyan
}
}
}
}

process {
    # 优化并行处理参数
    $ThrottleLimit = [math]::Min(100, [math]::Ceiling($Computers.Count/10))
    
    $Computers | ForEach-Object -ThrottleLimit $ThrottleLimit -Parallel {
        $Computer = $_
        $Result = [PSCustomObject]@{
            ComputerName = $Computer
            Status = $null
            Error = $null
            Timestamp = Get-Date
        }

        try {
            # 增加预连接检查
            if (-not (Test-EnterpriseConnection $Computer -Retries 2)) {
                throw "无法建立网络连接"
            }

            # 带重试机制的远程执行
            $retryCount = 0
            $maxRetries = 3
            do {
                try {
                    Invoke-Command @SessionParams -ScriptBlock {
                        param($Servers)
                        $Adapter = Get-NetAdapter -Physical | 
                                  Where-Object Status -eq 'Up' | 
                                  Select-Object -First 1

                        if (-not $Adapter) {
                            throw "找不到活动的物理网络适配器"
                        }

                        Set-DnsClientServerAddress -InterfaceIndex $Adapter.InterfaceIndex `
                                                  -ServerAddresses $Servers `
                                                  -Validate -ErrorAction Stop
                    } -ArgumentList $DNSServers

                        # 刷新DNS缓存
                        Register-DnsClient | Out-Null
                    ipconfig /registerdns | Out-Null
                    } -ArgumentList $DNSServers

                    $Result.Status = 'Success'
                }
                catch {
                    $Result.Status = 'Failed'
                    $Result.Error = $_.Exception.Message
                    $using:script:FailedComputers += $Computer
                }
                finally {
                    # 更新进度并记录日志
                    $Result | Export-Csv -Path $using:LogFile -Append -NoTypeInformation
                    [System.Threading.Interlocked]::Increment([ref]$using:SuccessCount) | Out-Null
                    $using:ProgressParams.PercentComplete = [math]::Round(($using:SuccessCount / $using:TotalComputers) * 100)
                    $using:ProgressParams.Status = "已完成 $($using:SuccessCount)/$($using:TotalComputers)"
                    Write-Progress @using:ProgressParams
                }
            }
        }
        catch {
            Write-Error "脚本执行过程中发生错误: $_"
            exit 1
        }
        finally {
            Write-Progress -Activity $ProgressParams.Activity -Completed
        }
    }
}
}
}
}
