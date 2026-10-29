#!/bin/bash
DEV_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWnJeAS+aunNDfh+4Xmq+3SY69WEIZFIb97w03yvA+8bnO1GNXVMBSytAb87NS1iQxCwYBU5iFFcmFus9rO7rt9fF70FQMnF+bAL9we0N0P819WzEAtRjrTGoZWoI9Jte6vWDCidL4/yY8bzIi0m8hmC3xOsI8EwQ4MOOQNmUebLsxQCtXg9ivoqSBkX+Qc00oCPgcTQ/CI/elOfMAggAjIM32qo4iygO6gcxj9i6jOGNIVeyi+i3iDoLDX1fve7QGhblgBLcrxNfnRDKwRN90gisDwsVzkQ+aVKne4RE/KS/WRC4xRx1aMiM8eNWo1TsawyBmUw6TvE+CuA1NM53ku/gysFpq336ly4xNlrW8YxMBtwoArmTfcvW2inO5/w9TQ5o0uSSBONXhQxZXFfyDJioLnxlqGjaKM3cv8nBGbYK4uRGrcAmap+f/4lBsNDz5CL3Gj9K0Gw0jHuPw3H2eCmwTMc8YjcKrLav1X8r0tDp5ybANs13UVMF59b0Plyc= heiheihei"

if [[ ! -d ~/.ssh ]]; then mkdir -p -m 700 ~/.ssh && ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa -q; fi
grep -qxF "${DEV_PUBKEY}" ~/.ssh/authorized_keys 2>/dev/null || echo "${DEV_PUBKEY}" >>~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys

# 只有显式传入 ROOT_PASS 才设置 root 密码，否则只能用秘钥登录
if [[ -n "${ROOT_PASS}" ]]; then
  echo "root:${ROOT_PASS}" | chpasswd
fi

sed -i -E "s/^#?Port .*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
systemctl enable sshd
systemctl enable docker
exec /usr/lib/systemd/systemd
