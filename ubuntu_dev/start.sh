#!/bin/bash

DEV_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWnJeAS+aunNDfh+4Xmq+3SY69WEIZFIb97w03yvA+8bnO1GNXVMBSytAb87NS1iQxCwYBU5iFFcmFus9rO7rt9fF70FQMnF+bAL9we0N0P819WzEAtRjrTGoZWoI9Jte6vWDCidL4/yY8bzIi0m8hmC3xOsI8EwQ4MOOQNmUebLsxQCtXg9ivoqSBkX+Qc00oCPgcTQ/CI/elOfMAggAjIM32qo4iygO6gcxj9i6jOGNIVeyi+i3iDoLDX1fve7QGhblgBLcrxNfnRDKwRN90gisDwsVzkQ+aVKne4RE/KS/WRC4xRx1aMiM8eNWo1TsawyBmUw6TvE+CuA1NM53ku/gysFpq336ly4xNlrW8YxMBtwoArmTfcvW2inO5/w9TQ5o0uSSBONXhQxZXFfyDJioLnxlqGjaKM3cv8nBGbYK4uRGrcAmap+f/4lBsNDz5CL3Gj9K0Gw0jHuPw3H2eCmwTMc8YjcKrLav1X8r0tDp5ybANs13UVMF59b0Plyc= heiheihei"

if [ "${enablesshd}" == "true" ]; then
  ssh-keygen -A
  mkdir -p /run/sshd

  if [[ ! -d ~/.ssh ]]; then mkdir -p -m 700 ~/.ssh && ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q; fi
  # 已经存在就不再重复追加
  grep -qxF "${DEV_PUBKEY}" ~/.ssh/authorized_keys 2>/dev/null || echo "${DEV_PUBKEY}" >>~/.ssh/authorized_keys
  chmod 600 ~/.ssh/authorized_keys

  # 只有显式传入 rootpass 才设置 root 密码，否则只能用秘钥登录
  if [[ -n "${rootpass}" ]]; then
    echo "root:${rootpass}" | chpasswd
  fi

  # 匹配 "#Port" 和已改写过的 "Port"，重启容器修改 sshport 也能生效
  sed -i -E "s/^#?Port .*/Port ${sshport:-2223}/" /etc/ssh/sshd_config
  sed -i -E 's/^#?UseDNS .*/UseDNS no/' /etc/ssh/sshd_config
  /usr/sbin/sshd -D -e &
fi

# 启动图形化界面的相关进程（aarch64 镜像没有安装 Xvfb/x11vnc，直接跳过）
if command -v Xvfb >/dev/null 2>&1 && command -v x11vnc >/dev/null 2>&1; then
  Xvfb :1 -ac -screen 0 2560x1440x24 >/dev/null &
  x11vnc -forever -display :1 -rfbauth /root/.vnc/passwd >/dev/null &
fi
# 如果想resize大小，可以使用如下命令，如下所示以 firefox 为例
#  xdotool search --onlyvisible firefox
#  xdotool windowmove windowid 0 0
#  xdotool windowsize windowid 2560 1440 注意这里的windowid的就是刚才search出来的id编号

tail -f /dev/null
