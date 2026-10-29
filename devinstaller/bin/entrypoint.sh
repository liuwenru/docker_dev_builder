#!/bin/bash
# 不用 set -e：/etc/devenv.sh 里 `[ ... ] && ...` 这类行返回非 0 是正常的

# docker run IMG <命令> 不经过 shell 时也带上开发环境（各 installer 写入的 /etc/devenv.sh）
[ -f /etc/devenv.sh ] && . /etc/devenv.sh

# jabba/nvm/gvm 是 shell 函数、vim 是别名，exec 找不到，只能在当前 shell 里执行
if declare -F "$1" >/dev/null 2>&1; then
  "$@"
  exit $?
fi
if alias "$1" >/dev/null 2>&1; then
  shopt -s expand_aliases
  eval "$(printf '%q ' "$@")"
  exit $?
fi

exec "$@"
