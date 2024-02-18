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
