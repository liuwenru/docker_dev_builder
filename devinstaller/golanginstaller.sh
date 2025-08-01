#!/bin/bash

if [[ $(uname -m) == "x86_64" ]]; then
  golangdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/golang/go1.24.5.linux-amd64.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
  golangdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/golang/go1.24.5.linux-arm64.tar.gz"
fi
curl -k -L -o /tmp/golang.tar.gz ${golangdownloadurl}
tar -zxf /tmp/golang.tar.gz -C /opt/
rm -rf /tmp/golang.tar.gz
