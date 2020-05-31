#!/bin/bash

# install lua

ostype=$(cat /etc/os-release | grep Ubuntu | wc -l)
if [[ ${ostype} -ge 1 ]]; then
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gcc \
    libc6-dev \
    make \
    libreadline-dev \
    dirmngr \
    gnupg \
    unzip
else
  yum -y install \
    ca-certificates \
    curl \
    gcc \
    glibc-devel \
    make \
    readline-devel \
    dirmngr \
    gnupg2 \
    unzip
fi
curl -k -o /tmp/lua.tar.gz "https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/lua-5.4.3.tar.gz"
mkdir /tmp/lua
tar -xf /tmp/lua.tar.gz -C /tmp/lua --strip-components=1
cd /tmp/lua && make linux && make install

# install lua package managers
curl -k -o /tmp/luarocks.tar.gz "https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/luarocks-3.7.0.tar.gz"
mkdir /tmp/luarocks
tar -xf /tmp/luarocks.tar.gz -C /tmp/luarocks --strip-components=1
cd /tmp/luarocks && ./configure && make && make install


# Clean installer tag files

rm -rf /tmp/lua*
