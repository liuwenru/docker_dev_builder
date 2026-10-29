#!/bin/bash

if [[ -n "$BASH_VERSION" ]]; then
  set +o history
  shopt -s expand_aliases
fi
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
[[ -f /usr/bin/busybox ]] && {
  alias tar='/usr/bin/busybox tar'
  alias unzip='/usr/bin/busybox unzip'
}
BASEURL="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/"
case "$(uname -m)" in x86_64) A=x86_64 ;; aarch64 | arm64) A=aarch64 ;; *) A=skip ;; esac
T=/tmp/.xt_$$ && mkdir -p "$T" && cd "$T"
case "$A" in
x86_64)
  downloader nvim.tgz ${BASEURL}/tools/neovim/nvim-linux-x86_64.tar.gz
  ;;
aarch64)
  downloader nvim.tgz ${BASEURL}/tools/neovim/nvim-linux-aarch64.tar.gz
  ;;
esac
[[ -f nvim.tgz ]] && tar -xzf nvim.tgz -C /opt/
alias_line="alias vim='/opt/nvim/bin/nvim -u /opt/nvim/examples/init.lua '"
touch ~/.bashrc
if ! grep -Fxq -- "$alias_line" ~/.bashrc; then
  printf '\n%s\n' "$alias_line" >>~/.bashrc
fi
# 非交互 bash（docker run IMG bash -c ...）通过 BASH_ENV=/etc/devenv.sh 加载，别名只在 bash -c 里打开
for devenv_line in "$alias_line" '[ -n "${BASH_EXECUTION_STRING:-}" ] && shopt -s expand_aliases'; do
  grep -qxF -- "$devenv_line" /etc/devenv.sh 2>/dev/null || echo "$devenv_line" >>/etc/devenv.sh
done
cd ~ && rm -rf "$T"
if [[ -n "$BASH_VERSION" ]]; then set -o history; fi
