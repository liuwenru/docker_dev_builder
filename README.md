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
docker buildx build --network=host --platform linux/amd64 \
  -t liuwenru/centos_dev:x86_64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-x86_64 . --load --progress=plain
docker buildx build --network=host --platform linux/arm64 \
  -t liuwenru/centos_dev:aarch64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-aarch64 . --load --progress=plain

```

默认使用 BuildKit 缓存以加快重复构建；仅在需要排查缓存问题或执行全量重建时手动添加 `--no-cache`。

所有构建脚本均位于仓库根目录，并统一使用仓库根目录作为 Docker build context：

```bash
./build_centos7.sh
./build_fedora.sh
./build_rockylinux.sh
./build_ubuntu.sh
```

脚本会根据宿主机架构选择 x86_64 或 aarch64 Dockerfile，并在 tag 后追加 `$(date +%Y%m%d-%H%M)`，形如 `liuwenru/<name>_dev:<arch>-20260707-1830`。

需要忽略 Dockerfile 层缓存并执行全量构建时，向脚本传入 `--no-cache`：

```bash
./build_fedora.sh --no-cache
```

Dockerfile 按工具链划分了命名阶段，可通过 `--target` 只构建到指定阶段。例如只构建 Ubuntu x86_64 的 Go 开发环境：

```bash
docker build --network=host --target golangdev \
  -f ubuntu_dev/Dockerfile-x86_64 \
  -t liuwenru/ubuntu_dev:x86_64-golangdev .
```

通用阶段依次为 `base`、`toolsdev`、`cdev`、`golangdev`、`pydev`、`javadev`、`nodedev`、`final`。CentOS 7 aarch64 不包含 `pydev`，Rocky Linux 在 `nodedev` 后额外包含 `dockerdev`。
