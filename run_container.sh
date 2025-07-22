#!/bin/bash
IMAGE_NAME="qcom-sdk-amd64"
CONTAINER_ID=$(docker ps -a --filter "ancestor=$IMAGE_NAME" --format "{{.ID}}" | head -n 1)

HOST_DIR="$1"
VOLUME_MOUNTS="-v \"$(pwd)/.env:/app/.env\""
if [ -n "$HOST_DIR" ]; then
    VOLUME_MOUNTS="$VOLUME_MOUNTS -v \"$HOST_DIR:/workspace\""
    echo "=> 将宿主机目录 $HOST_DIR 映射到容器 /workspace"
fi

if [ -n "$CONTAINER_ID" ]; then
    if [ "$(docker ps -q -f id=$CONTAINER_ID)" ]; then
        echo "=> 容器 ($CONTAINER_ID) 已在运行中。"
    else
        echo "=> 发现已存在的容器 ID: $CONTAINER_ID"
        echo "=> 正在后台启动容器..."
        docker start $CONTAINER_ID
        # 确保容器内的代理服务已启动
        sleep 5
    fi
    echo "=> 进入容器交互环境..."
    docker exec -it $CONTAINER_ID bash -c 'export ANDROID_NDK_ROOT=/opt/android-ndk-r26c; export PATH=${ANDROID_NDK_ROOT}:${PATH}; cd /opt/qcom/aistack/qairt/2.31.0.250130/bin; source ./envsetup.sh >/dev/null 2>&1; exec /bin/bash'
    docker stop $CONTAINER_ID
else
    echo "=> 未找到已存在的容器，正在首次启动并进入交互环境..."
    eval docker run -it $VOLUME_MOUNTS $IMAGE_NAME /bin/bash
fi