#!/bin/bash

# bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

if [[ $(uname -m) == "x86_64" ]]; then
  cp /opt/devinstaller/bin/tini-static-amd64 /tini
elif [[ $(uname -m) == "aarch64" ]]; then
  cp /opt/devinstaller/bin/tini-static-arm64 /tini
fi

chmod +x /tini

curl -k -o /root/.gitconfig https://raw.githubusercontent.com/liuwenru/mymacprofile/master/git/gitconfig
curl -k -o /root/.gitignore_global https://raw.githubusercontent.com/liuwenru/mymacprofile/master/git/gitignore_global

# bash tools

set +o history
curl -k -o /tmp/bashit.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/bashit-v3.0.3.tar.gz
mkdir ~/.bash_it
tar -zxf /tmp/bashit.tar.gz --strip-components 1 -C ~/.bash_it
~/.bash_it/install.sh --silent --append-to-config
if [[ $(uname -m) == "x86_64" ]]; then
  curl -k -o /tmp/fzf.tar.gz -L https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.45.0-linux_amd64.tar.gz
elif [[ $(uname -m) == "aarch64" ]]; then
  curl -k -o /tmp/fzf.tar.gz -L https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.45.0-linux_arm64.tar.gz
fi
mkdir ~/.fzf
curl -k -o /tmp/fzfinstall.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.45.0.tar.gz
tar --strip-components=1 -zxf /tmp/fzfinstall.tar.gz -C ~/.fzf/
tar -zxf /tmp/fzf.tar.gz -C ~/.fzf/bin
cd ~/.fzf && ./install --all
echo "alias ll='ls -lh'" >>~/.bashrc
sed -i 's/export SCM_CHECK=true/export SCM_CHECK=false/g' ~/.bashrc
source ~/.bashrc
set -o history

# install git
curl -k -L -o /tmp/git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.44.0.tar.gz

mkdir /tmp/git && cd /tmp/git && tar --strip-components=1 -zxf /tmp/git.tar.gz -C /tmp/git
./configure --prefix=/opt/git2.44 && make -j$(nproc) && make install && ln -s /opt/git2.44 /usr/local/git
