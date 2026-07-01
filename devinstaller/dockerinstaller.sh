#!/usr/bin/env bash
set -euo pipefail

mkdir -p /usr/local/lib/docker/cli-plugins
if [[ $(uname -m) == "x86_64" ]]; then
  curl -k -L -o /tmp/docker.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/docker/amd64/docker-27.3.1.tgz
  curl -k -L -o /usr/local/lib/docker/cli-plugins/docker-compose https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/docker/amd64/docker-compose-linux-x86_64
  curl -k -L -o /usr/local/lib/docker/cli-plugins/docker-buildx https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/docker/amd64/buildx-v0.25.0.linux-amd64
elif [[ $(uname -m) == "aarch64" ]]; then
  curl -k -L -o /tmp/docker.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/docker/aarch64/docker-27.3.1.tgz
  curl -k -L -o /usr/local/lib/docker/cli-plugins/docker-compose https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/docker/aarch64/docker-compose-linux-aarch64
  curl -k -L -o /usr/local/lib/docker/cli-plugins/docker-buildx https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/docker/aarch64/buildx-v0.25.0.linux-arm64
fi
tar --strip-components=1 -xzvf /tmp/docker.tar.gz -C /usr/bin/ && rm -rf /tmp/docker.tar.gz
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
/bin/cp -rf /usr/local/lib/docker/cli-plugins/docker-compose /usr/bin
chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
