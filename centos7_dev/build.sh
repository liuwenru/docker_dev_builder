#!/bin/bash
if [[ -d devinstaller ]]; then
  rm -rf devinstaller
fi
cp -r ../devinstaller ./devinstaller

if [[ $(uname -m) == "x86_64" ]]; then
  DOCKER_BUILDKIT=0 docker build --no-cache --network=host -f Dockerfile-x86_64  -t liuwenru/centos_dev:$(uname -m) .
elif [[ $(uname -m) == "aarch64" ]]; then
  DOCKER_BUILDKIT=0 docker build --no-cache --network=host -f Dockerfile-aarch64 -t liuwenru/centos_dev:$(uname -m) .
fi

rm -rf devinstaller
