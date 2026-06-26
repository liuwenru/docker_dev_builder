#!/bin/bash


wget -qO- https://astral.sh/uv/install.sh | sh


downloadurl=https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.12.11.tgz

wget --no-check-certificate -O /tmp/Python.tgz ${downloadurl}
mkdir /tmp/python && cd /tmp/python && tar --strip-components=1 -zxvf /tmp/Python.tgz -C ./

./configure \
  --prefix=/opt/python312 \
  --enable-optimizations \
  --with-lto \
  --enable-shared \
  --with-ensurepip=install
make -j$(nproc)
make altinstall


