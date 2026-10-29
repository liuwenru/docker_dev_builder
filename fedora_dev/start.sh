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
  /usr/sbin/sshd -D -e
fi
