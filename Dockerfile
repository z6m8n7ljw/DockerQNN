FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

ARG HOST_HTTP_PROXY
ARG HOST_HTTPS_PROXY
ENV http_proxy=$HOST_HTTP_PROXY
ENV https_proxy=$HOST_HTTPS_PROXY

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    software-properties-common \
    shadowsocks-libev \
    proxychains4 \
    wget \
    curl \
    ca-certificates \
    gnupg \
    sudo \
    bc \
    clang \
    build-essential \
    python3-pip \
    unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV http_proxy=""
ENV https_proxy=""

# 创建 shadowsocks 配置目录并将自定义配置文件复制进去
COPY config.json /etc/shadowsocks-libev/config.json

# 复制 qpm-cli 安装包到容器中
COPY QualcommPackageManager3.3.0.121.7.Linux-x86.deb /tmp/qpm-cli.deb

# 配置 proxychains4 使用 shadowsocks 代理
# 默认配置文件是 /etc/proxychains4.conf
# 将默认的 "socks4 127.0.0.1 9050" 替换为自定义配置
RUN sed -i -e 's/socks4\s*127.0.0.1\s*9050/socks5 127.0.0.1 1080/' /etc/proxychains4.conf

# 复制并设置入口点脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置工作目录
WORKDIR /app

# 设置容器的入口点
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# 默认命令改为一个常驻进程，以保持容器在后台运行。
# 用户可以通过 `docker exec` 进入 shell，或者在 `docker run` 时覆盖此命令。
CMD ["tail", "-f", "/dev/null"]