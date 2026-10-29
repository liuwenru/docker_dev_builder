#!/bin/bash
# 非交互 bash 的 BASH_ENV 入口（Dockerfile final 阶段 ENV BASH_ENV=/etc/bash_env.sh）
# 实际内容在 /etc/devenv.sh，由各 installer 追加。
# gvm/nvm 的初始化脚本在 set -e/-u 下会报错退出，所以加载时临时关掉，加载完恢复调用方的设置
__devenv_opts=$-
set +eu
[ -f /etc/devenv.sh ] && . /etc/devenv.sh
[[ $__devenv_opts == *e* ]] && set -e
[[ $__devenv_opts == *u* ]] && set -u
unset __devenv_opts
true
