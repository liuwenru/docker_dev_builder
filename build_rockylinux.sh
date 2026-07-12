#!/bin/bash
set -e

cd "$(dirname "$0")"

IMAGE_NAME="liuwenru/rockylinux_dev"
BUILD_DATE="$(date +%Y%m%d-%H%M)"
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
    docker build "${BUILD_ARGS[@]}" --network=host -f rockylinux_dev/Dockerfile-x86_64 \
      -t "${IMAGE_NAME}:x86_64-${BUILD_DATE}" .
    ;;
  aarch64)
    docker build "${BUILD_ARGS[@]}" --network=host -f rockylinux_dev/Dockerfile-aarch64 \
      -t "${IMAGE_NAME}:aarch64-${BUILD_DATE}" .
    ;;
  *)
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac
