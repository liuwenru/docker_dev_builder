#!/usr/bin/env bash
set -euo pipefail
# install lua

# if grep -qi ubuntu /etc/os-release; then
#   apt-get install -y --no-install-recommends ca-certificates curl gcc libc6-dev make libreadline-dev dirmngr gnupg unzip
# elif command -v dnf >/dev/null 2>&1; then
#   dnf -y --allowerasing install ca-certificates curl gcc glibc-devel make readline-devel dirmngr gnupg2 unzip
# else
#   yum -y --allowerasing install ca-certificates curl gcc glibc-devel make readline-devel dirmngr gnupg2 unzip
# fi

. /etc/os-release

if [[ "$ID" == "ubuntu" ]]; then
  apt-get install -y --no-install-recommends \
    ca-certificates curl gcc libc6-dev make libreadline-dev dirmngr gnupg unzip

elif command -v dnf >/dev/null 2>&1; then
  if [[ "$ID" == "fedora" ]]; then
    dnf -y --setopt=keepcache=True install \
      ca-certificates curl gcc glibc-devel make readline-devel dirmngr gnupg2 unzip
  else
    dnf -y --setopt=keepcache=True --allowerasing install \
      ca-certificates curl gcc glibc-devel make readline-devel dirmngr gnupg2 unzip
  fi

else
  yum -y --setopt=keepcache=1 --allowerasing install \
    ca-certificates curl gcc glibc-devel make readline-devel dirmngr gnupg2 unzip
fi

curl -k -L -o /tmp/lua.tar.gz "https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/lua-5.4.3.tar.gz"
mkdir /tmp/lua
tar -xf /tmp/lua.tar.gz -C /tmp/lua --strip-components=1
cd /tmp/lua && make linux && make install

# install lua package managers
curl -k -L -o /tmp/luarocks.tar.gz "https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/luarocks-3.7.0.tar.gz"
mkdir /tmp/luarocks
tar -xf /tmp/luarocks.tar.gz -C /tmp/luarocks --strip-components=1
cd /tmp/luarocks && ./configure && make && make install

# Clean installer tag files

rm -rf /tmp/lua*
