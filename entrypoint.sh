#!/bin/bash
set -e

INIT_MARKER="/app/.initialized"

echo "=> 正在后台启动 Shadowsocks 客户端..."
ss-local -c /etc/shadowsocks-libev/config.json -v &
echo "=> 等待 ss-local 服务短暂启动..."
sleep 5

if [ ! -f "$INIT_MARKER" ]; then
    echo "=> 首次运行，正在执行一次性初始化..."

    echo "=> 安装 qpm-cli..."
    dpkg -i /tmp/qpm-cli.deb
    rm /tmp/qpm-cli.deb

    echo "=> 通过代理登录并安装 Qualcomm AI Engine Direct..."
    if [ -f .env ]; then
      export $(grep -v '^#' .env | xargs)
    fi
    proxychains4 qpm-cli --login "$QCOM_USER" "$QCOM_PASSWORD"
    yes | proxychains4 qpm-cli --install qualcomm_ai_engine_direct -v 2.31.0.250130

    echo "=> 安装 onnx 1.17.0..."
    proxychains4 pip3 install onnx==1.17.0

    echo "=> 下载并安装 Android NDK r26c..."
    cd /opt
    proxychains4 wget https://dl.google.com/android/repository/android-ndk-r26c-linux.zip
    unzip android-ndk-r26c-linux.zip
    rm android-ndk-r26c-linux.zip

    export ANDROID_NDK_ROOT=/opt/android-ndk-r26c
    export PATH=${ANDROID_NDK_ROOT}:${PATH}
    echo "export ANDROID_NDK_ROOT=/opt/android-ndk-r26c" >> /etc/environment
    echo "export PATH=\${ANDROID_NDK_ROOT}:\${PATH}" >> /etc/environment

    cd /app
    
    echo "=> 初始化完成，创建标记文件。"
    touch $INIT_MARKER
else
    echo "=> 检测到标记文件，跳过初始化。"
fi

cd /app
if [ -d "/opt/qcom/aistack/qairt/2.31.0.250130" ]; then
    cd /opt/qcom/aistack/qairt/2.31.0.250130
fi

echo "=> 容器已就绪。"

exec "$@"