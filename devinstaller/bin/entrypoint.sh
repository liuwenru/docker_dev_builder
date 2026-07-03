#!/bin/bash
set -e

# 自己加载登录环境
source /etc/profile
source /root/.bash_profile 2>/dev/null || true

exec "$@"