#!/bin/bash
docker system prune -a -f
docker buildx build \
    --platform linux/amd64 \
    --build-arg HOST_HTTP_PROXY=http://host.docker.internal:1080 \
    --build-arg HOST_HTTPS_PROXY=http://host.docker.internal:1080 \
    -t qcom-sdk-amd64 . --load