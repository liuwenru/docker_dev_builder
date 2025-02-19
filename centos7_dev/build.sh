#!/bin/bash
if [[ -d devinstaller ]]; then
  rm -rf devinstaller
fi
cp -r ../devinstaller ./devinstaller

if [[ $1 == "amd64" ]]; then
  DOCKER_BUILDKIT=0 DOCKER_HOST=ssh://root@192.168.188.150 docker build --no-cache --network=host -f Dockerfile-x86_64 -t liuwenru/centos_dev:x86_64 .
elif [[ $1 == "aarch64" ]]; then
  DOCKER_BUILDKIT=0 DOCKER_HOST=ssh://root@192.168.182.150 docker build --no-cache --network=host -f Dockerfile-aarch64 -t liuwenru/centos_dev:aarch64 .
fi

rm -rf devinstaller
