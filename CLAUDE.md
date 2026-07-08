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

# Build using convenience script (fedora/rockylinux/ubuntu)
cd fedora_dev && ./build.sh
cd rockylinux_dev && ./build.sh
cd ubuntu_dev && ./build.sh
```

说明：所有 `build.sh` 内部都会在 tag 后追加 `$(date +%Y%m%d-%H%M)`（宿主机本地时间），
形如 `liuwenru/<name>_dev:<arch>-20260707-1830`，便于区分多次构建产物。

## Architecture

- **Multi-stage Dockerfiles**: Base → cdev (C/C++ tools) → golangdev → nodedev → pydev → javadev
- **devinstaller/**: Shared installer scripts copied into images at build time
  - `cinstall.sh` - C/C++ development tools
  - `golanginstaller.sh` - Go toolchain
  - `nodejsinstaller.sh`, `pyinstaller.sh`, `javainstaller.sh` - respective language runtimes
  - `toolsinstall.sh` - Git,平时的开发工具
  - `download-vs-code.sh` - Downloads VSCode server with custom glibc patch support
- **start.sh**: Entry point script in each distro folder
- **cuda-dockerd/**: Separate CUDA-enabled image with systemd and SSH daemon for GPU workloads

## VSCode Integration

- **vscodedevsettings/**: DevContainer and VSCode launch configurations for connecting to running containers
- **vscode-plugin-list.txt**: Canonical list of VSCode extensions to install in the dev environment