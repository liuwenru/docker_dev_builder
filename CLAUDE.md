# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Docker-based development environment images for VSCode Remote-SSH development. Each distribution (centos7, fedora, ubuntu, rockylinux) has multi-arch Dockerfile variants (x86_64, aarch64).

## Building Images

```bash
# Setup buildx builder (one-time)
docker buildx create --use --name mybuilder --driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host'

# Build centos7 dev image (tag includes build date YYYYMMDD-HHMM, host local time)
docker buildx build --no-cache --network=host --platform linux/amd64 \
  -t liuwenru/centos_dev:x86_64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-x86_64 . --load --progress=plain
docker buildx build --no-cache --network=host --platform linux/arm64 \
  -t liuwenru/centos_dev:aarch64-$(date +%Y%m%d-%H%M) \
  -f centos7_dev/Dockerfile-aarch64 . --load --progress=plain

# Build using convenience scripts in repo root (auto-detects host arch, optional --no-cache)
./build_centos7.sh
./build_fedora.sh
./build_rockylinux.sh
./build_ubuntu.sh
```

说明：所有 `build_*.sh` 的 tag 为 `<arch>-$(date +%Y%m%d%H%M)-$(git rev-parse --short HEAD)`（宿主机本地时间 + 当前提交短 id），
形如 `docker.io/liuwenru/<name>_dev:x86_64-202610300549-8308a41`，便于区分多次构建产物并对应到代码版本。

## Architecture

- **Multi-stage Dockerfiles**: base → toolsdev → cdev (C/C++ tools) → golangdev → pydev → javadev → nodedev → final（CentOS 7 aarch64 没有 pydev，Rocky Linux 在 nodedev 后多一个 dockerdev）
- **devinstaller/**: Shared installer scripts copied into images at build time
  - `cinstall.sh` - C/C++ development tools
  - `golanginstaller.sh` - Go toolchain
  - `nodejsinstaller.sh`, `pyinstaller.sh`, `javainstaller.sh` - respective language runtimes
  - `toolsinstall.sh` - Git,平时的开发工具
  - `download-vs-code.sh` - Downloads VSCode server with custom glibc patch support
- **start.sh**: Entry point script in each distro folder
- **/etc/devenv.sh**：非交互 bash 的环境（final 阶段 `ENV BASH_ENV=/etc/bash_env.sh`，这个包装脚本（`devinstaller/bin/bash_env.sh`）会临时关掉 `set -eu` 再 source 它；`/entrypoint.sh` 也会 source 它）。
  没有单独的源文件，由各 installer 在往 `~/.bashrc` 写初始化代码的同时用 `grep -qxF ... || echo ... >>/etc/devenv.sh` 追加。
  新增工具时同样处理；starship/atuin/bash-preexec 这类只对交互 shell 有用的不要写进去。
- **cuda-dockerd/**: Separate CUDA-enabled image with systemd and SSH daemon for GPU workloads

## VSCode Integration

- **vscodedevsettings/**: DevContainer and VSCode launch configurations for connecting to running containers
- **vscode-plugin-list.txt**: Canonical list of VSCode extensions to install in the dev environment