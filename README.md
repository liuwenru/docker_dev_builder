# docker_dev_builder

基于 docker 镜像构建一个日常的开发环境，方便开发，直接使用 vscode 的 Remote-SSH 工具进行开发.

为了更快速的构建，使用了 docker 的 buildx 套件

```bash

docker buildx create --use --name mybuilder --driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host'

docker buildx build --network=host --platform linux/amd64 \
  -t liuwenru/centos_dev:x86_64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-x86_64 . --load
# 使用如下命令行获取已经安装的插件
code --list-extensions| sort -f


```

```bash
# 构建centos开发镜像 (tag 末尾的 YYYYMMDD-HHMM 由宿主机本地 `date +%Y%m%d-%H%M` 生成)
docker buildx build --no-cache --network=host --platform linux/amd64 \
  -t liuwenru/centos_dev:x86_64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-x86_64 . --load --progress=plain
docker buildx build --no-cache --network=host --platform linux/arm64 \
  -t liuwenru/centos_dev:aarch64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-aarch64 . --load --progress=plain

```

fedora/rockylinux/ubuntu 可直接进入对应目录运行 `./build.sh`，同样会在 tag 后追加 `$(date +%Y%m%d-%H%M)`，形如 `liuwenru/<name>_dev:<arch>-20260707-1830`。
