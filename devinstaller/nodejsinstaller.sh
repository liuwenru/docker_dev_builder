#!/usr/bin/env bash
# set -euo pipefail

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
source ~/.bashrc
nvm install 24
nvm alias default 24

# 非交互 bash（docker run IMG bash -c ...）通过 BASH_ENV=/etc/devenv.sh 加载
for devenv_line in 'export NVM_DIR="$HOME/.nvm"' '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"'; do
  grep -qxF "$devenv_line" /etc/devenv.sh 2>/dev/null || echo "$devenv_line" >>/etc/devenv.sh
done
