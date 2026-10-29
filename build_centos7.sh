#!/bin/bash
set -e

cd "$(dirname "$0")"

IMAGE_NAME="docker.io/liuwenru/centos_dev"
BUILD_DATE="$(date +%Y%m%d%H%M)"
# tag 带上当前 git 提交的短 id，方便对应到代码版本
GIT_ID="$(git rev-parse --short HEAD)"
BUILD_ARGS=()

if [[ $# -gt 1 ]] || [[ $# -eq 1 && $1 != "--no-cache" ]]; then
  echo "Usage: $0 [--no-cache]" >&2
  exit 1
fi
if [[ ${1:-} == "--no-cache" ]]; then
  BUILD_ARGS+=(--no-cache)
fi

case "$(uname -m)" in
  x86_64)
    docker build "${BUILD_ARGS[@]}" --network=host -f centos7_dev/Dockerfile-x86_64 \
      -t "${IMAGE_NAME}:x86_64-${BUILD_DATE}-${GIT_ID}" .
    ;;
  aarch64)
    docker build "${BUILD_ARGS[@]}" --network=host -f centos7_dev/Dockerfile-aarch64 \
      -t "${IMAGE_NAME}:aarch64-${BUILD_DATE}-${GIT_ID}" .
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac
