# Minikube 部署指南

## 1. 代理配置
```bash
minikube start --force \
  --docker-env=HTTP_PROXY=http://your-company-proxy:8080 \
  --docker-env=HTTPS_PROXY=http://your-company-proxy:8080
```

## 2. kubectl 安装
1. 下载最新版kubectl：
```powershell
$proxy = "http://your-company-proxy:8080"
$version = (Invoke-RestMethod https://storage.googleapis.com/kubernetes-release/release/stable.txt -Proxy $proxy).Substring(1)
$url = "https://storage.googleapis.com/kubernetes-release/release/v$version/bin/windows/amd64/kubectl.exe"
Invoke-WebRequest -Uri $url -OutFile $env:USERPROFILE\kubectl.exe -Proxy $proxy
```

2. 添加环境变量：
```powershell
[Environment]::SetEnvironmentVariable("Path", "$env:Path;$env:USERPROFILE", "User")
```

## 3. 验证安装
```bash
minikube kubectl -- get pods -A
```









:set number