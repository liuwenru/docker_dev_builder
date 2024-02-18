#!/bin/bash
if [[ -d devinstaller ]]; then
  rm -rf devinstaller
fi
cp -r ../devinstaller ./devinstaller

if [[ $(uname -m) == "x86_64" ]]; then
  docker build --no-cache --builder mybuilder --network=host -f Dockerfile --load -t liuwenru/centos_dev:$(uname -m) .
elif [[ $(uname -m) == "aarch64" ]]; then
  docker build --no-cache --network=host -f Dockerfile_aarch64 -t liuwenru/centos_dev:$(uname -m) .
fi

rm -rf devinstaller
