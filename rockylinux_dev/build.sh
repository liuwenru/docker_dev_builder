#!/bin/bash
set -e # 顺便加上，遇到错误立即退出

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
