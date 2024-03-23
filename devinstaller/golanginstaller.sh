#!/bin/bash

if [[ $(uname -m) == "x86_64" ]]; then
  golangdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/go1.21.5.linux-amd64.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
  golangdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/go1.21.5.linux-arm64.tar.gz"
fi
curl -L -k -o /tmp/golang.tar.gz ${golangdownloadurl}
tar -zxf /tmp/golang.tar.gz -C /opt/
mkdir /opt/goworkspace
rm -rf /tmp/golang.tar.gz
