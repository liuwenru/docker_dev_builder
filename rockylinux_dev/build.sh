#!/bin/bash
set -e # 顺便加上，遇到错误立即退出

# 说明:
#   - dnf 包缓存和 ccache(/root/.ccache) 由 Docker BuildKit 的
#     --mount=type=cache 自动管理, 缓存在 buildkit 端(~/.cache/buildkit/),
#     多次构建间复用, 无需本脚本处理.
#   - 首次构建会做全量编译, 后续构建命中 ccache 后 Python 编译显著加速.

cleanup() {
  rm -rf devinstaller
}
trap cleanup EXIT # 脚本退出时（包括 ctrl-c、报错、正常结束）都会执行

if [[ -d devinstaller ]]; then
  rm -rf devinstaller
fi
cp -r ../devinstaller ./devinstaller

if [[ $(uname -m) == "x86_64" ]]; then
  docker build --network=host -f Dockerfile-x86_64 -t liuwenru/rockylinux_dev:$(uname -m) .
elif [[ $(uname -m) == "aarch64" ]]; then
  docker build --network=host -f Dockerfile-aarch64 -t liuwenru/rockylinux_dev:$(uname -m) .
fi
