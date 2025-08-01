# docker_dev_builder

基于 docker 镜像构建一个日常的开发环境，方便开发，直接使用 vscode 的 Remote-SSH 工具进行开发.

为了更快速的构建，使用了 docker 的 buildx 套件

```bash

docker buildx create --use --name mybuilder --driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host'

docker buildx build --network=host --platform linux/amd64 -t liuwenru/centos_dev:x86_64 -f centos7_dev/Dockerfile-x86_64 . --load
# 使用如下命令行获取已经安装的插件
code --list-extensions| sort -f


```

```bash
# 构建centos开发镜像
docker buildx build --no-cache --network=host --platform linux/amd64 -t liuwenru/centos_dev:x86_64 -f centos7_dev/Dockerfile-x86_64 . --load --progress=plain
docker buildx build --no-cache --network=host --platform linux/arm64 -t liuwenru/centos_dev:aarch64 -f centos7_dev/Dockerfile-aarch64 . --load --progress=plain

```
