#!/usr/bin/env bash
# set -euo pipefail

if [[ $(uname -m) == "x86_64" ]]; then
  golangdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/golang/go1.24.5.linux-amd64.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
  golangdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/golang/go1.24.5.linux-arm64.tar.gz"
fi
curl -k -L -o /tmp/golang.tar.gz ${golangdownloadurl}
tar -zxf /tmp/golang.tar.gz -C /opt/
rm -rf /tmp/golang.tar.gz

if grep -qi ubuntu /etc/os-release; then
  apt-get install -y --no-install-recommends bison git
elif command -v dnf >/dev/null 2>&1; then
  dnf -y --setopt=keepcache=True install bison git
else
  yum -y --setopt=keepcache=1 install bison git
fi

bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
source /root/.gvm/scripts/gvm
gvm install go1.26.4 -B

# 非交互 bash（docker run IMG bash -c ...）通过 BASH_ENV=/etc/devenv.sh 加载
devenv_line='[[ -s "/root/.gvm/scripts/gvm" ]] && source "/root/.gvm/scripts/gvm"'
grep -qxF "$devenv_line" /etc/devenv.sh 2>/dev/null || echo "$devenv_line" >>/etc/devenv.sh
