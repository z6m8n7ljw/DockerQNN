# Qualcomm® AI Engine Direct SDK 镜像
本项目为在 macOS (Apple Silicon) 上使用 Docker 构建安装了 Qualcomm®AI Engine Direct SDK 的 Ubuntu 22.04 (amd64) 环境。

## 宿主机环境准备
- ClashX
- Docker Desktop

```bash
# 安装 Git LFS (以 macOS Homebrew 为例)
brew install git-lfs

# 初始化 LFS
git lfs install

git clone https://github.com/z6m8n7ljw/DockerQNN.git
```

### 宿主机设置代理
ClashX 需设置为`Allow connect from LAN`，同时将端口设置为`1080`。

### Docker Desktop 设置代理
`Settings` -> `Resources` -> `Proxies` -> `Manual proxy configuration`

填写以下内容：
| 配置项 | 值 |
|--------|-----|
| Web Server (HTTP) | `http://127.0.0.1:1080` |
| Secure Web Server (HTTPS) | `http://127.0.0.1:1080` |
| Bypass proxy for | `localhost, 127.0.0.1, *.local, host.docker.internal` |

## 镜像构建
1. 需在根目录创建一个 `config.json` 文件，内容如下：
```json
{
    "server": "xxx.xxx.xxx.xxx",
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "timeout": 300,
    "workers": 1,
    "server_port": "xxx",
    "password": "xxx",
    "method": "rc4-md5",
    "plugin": ""
}
```
它将被用于配置容器的 Shadowsocks 代理。

2. 在根目录创建一个 `.env` 文件，内容如下：
```
QCOM_USER=xxx
QCOM_PASSWORD=xxx
```
它们为登陆 https://www.qualcomm.com/developer/software/qualcomm-ai-engine-direct-sdk 的账号密码。

3. Qualcomm® Package Manager 3 安装包下载地址：https://qpm.qualcomm.com/#/main/tools/details/QPM3
若有新版本更新，需将其替换本地的 `QualcommPackageManager3.3.0.121.7.Linux-x86.deb` 文件，同时修改 Dockerfile 中的 `COPY` 命令。

4. 运行脚本
```bash
./build_image.sh
```

## 容器启动
若要更新镜像所安装的 Qualcomm AI Engine Direct SDK 版本，需修改 `entrypoint.sh` 中的以下内容：
```bash
# ...
proxychains4 qpm-cli --install qualcomm_ai_engine_direct -v 2.31.0.250130
# ...
cd qcom/aistack/qairt/2.31.0.250130/bin
# ...
```
以及 `run_container.sh` 中的以下内容：
```bash
# ...
docker exec -it $CONTAINER_ID bash -c 'export ANDROID_NDK_ROOT=/opt/android-ndk-r26c; export PATH=${ANDROID_NDK_ROOT}:${PATH}; cd /opt/qcom/aistack/qairt/2.31.0.250130/bin; source ./envsetup.sh >/dev/null 2>&1; exec /bin/bash'
# ...
```

SDK 的依赖为 `Python 3.10`，`onnx 1.18.0`，`onnxruntime 1.22.1`，`onnx-simplifier 0.4.36`，`Android NDK r26c`… 这些均在脚本中安装。

```bash
./run_container.sh
```
每次通过`exit`退出容器的交互式终端，下一次运行仍然执行此脚本。
若需要映射宿主机的目录到容器中，则运行脚本时在后面添加宿主机目录，如：
```bash
./run_container.sh [宿主机目录]
```
