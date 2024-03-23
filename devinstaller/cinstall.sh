#!/bin/bash
workdir=$(pwd)
os=$(cat /etc/os-release | grep -E "^NAME=(.*)" | sed 's/NAME=//g' | sed 's/"//g' | tr -s '\n')
if [[ $(uname -m) == "x86_64" ]]; then
  echo "x86_64"
  # install glibc
  if [[ ${os} == "CentOS Linux" ]]; then
    curl -k -o /tmp/glibc2.18.tar.gz https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/glibc-2.18.tar.gz
    mkdir /tmp/glibcbuild
    tar --strip-components=1 -zxf /tmp/glibc2.18.tar.gz -C /tmp/glibcbuild
    cd /tmp/glibcbuild && mkdir build && cd build && ../configure --prefix=/opt/glibc2.18 && make -j$(nproc) && make install
    ln -s /opt/glibc2.18 /usr/local/glibc
    rm -rf /tmp/glibc2.18.tar.gz /opt/glibcbuild
  fi

  # install cmake
  curl -k -L -o /tmp/cmake.tar.gz https://github.com/Kitware/CMake/releases/download/v3.28.4/cmake-3.28.4-linux-x86_64.tar.gz
  mkdir /opt/cmake3.28
  tar --strip-components=1 -zxf /tmp/cmake.tar.gz -C /opt/cmake3.28
  ln -s /opt/cmake3.28 /usr/local/cmake
  # install clangd
  cat <<EOF >/usr/local/bin/clangd
#!/usr/bin/env bash
/usr/local/glibc/lib/ld-2.18.so /usr/local/clangd/bin/clangd $@
EOF
  chmod +x /usr/local/bin/clangd
  curl -k -L -o /tmp/clangd.zip https://github.com/clangd/clangd/releases/download/17.0.3/clangd-linux-17.0.3.zip
  unzip /tmp/clangd.zip -d /opt/
  ln -s /opt/clangd_17.0.3 /usr/local/clangd
  rm -rf /tmp/clangd.zip

  # install ctags
  curl -k -L -o /tmp/ctags.tar.gz https://github.com/universal-ctags/ctags/releases/download/v6.1.0/universal-ctags-6.1.0.tar.gz
  mkdir /tmp/ctags && cd /tmp/ctags
  tar --strip-components=1 -zxf /tmp/ctags.tar.gz -C /tmp/ctags
  ./autogen.sh
  ./configure --prefix=/opt/ctags6.1 && make -j$(nproc) && make install && ln -s /opt/ctags6.1 /usr/local/ctags
elif [[ $(uname -m) == "aarch64" ]]; then
  echo "aarch64"
fi

cd ${workdir}
