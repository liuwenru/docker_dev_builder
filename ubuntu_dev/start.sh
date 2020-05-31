#/bin/bash

if [ "${enablesshd}" == "true" ]; then
  test -f /etc/ssh/ssh_host_ecdsa_key || /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N ''
  test -f /etc/ssh/ssh_host_rsa_key || /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
  test -f /etc/ssh/ssh_host_ed25519_key || /usr/bin/ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''
  test -f /root/.ssh/id_rsa || /usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
  test -f /root/.ssh/id_rsa.pub || ssh-keygen -y -t rsa -f ~/.ssh/id_rsa >~/.ssh/id_rsa.pub
  test -f /root/.ssh/authorized_keys || /usr/bin/cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

  echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDWnJeAS+aunNDfh+4Xmq+3SY69WEIZFIb97w03yvA+8bnO1GNXVMBSytAb87NS1iQxCwYBU5iFFcmFus9rO7rt9fF70FQMnF+bAL9we0N0P819WzEAtRjrTGoZWoI9Jte6vWDCidL4/yY8bzIi0m8hmC3xOsI8EwQ4MOOQNmUebLsxQCtXg9ivoqSBkX+Qc00oCPgcTQ/CI/elOfMAggAjIM32qo4iygO6gcxj9i6jOGNIVeyi+i3iDoLDX1fve7QGhblgBLcrxNfnRDKwRN90gisDwsVzkQ+aVKne4RE/KS/WRC4xRx1aMiM8eNWo1TsawyBmUw6TvE+CuA1NM53ku/gysFpq336ly4xNlrW8YxMBtwoArmTfcvW2inO5/w9TQ5o0uSSBONXhQxZXFfyDJioLnxlqGjaKM3cv8nBGbYK4uRGrcAmap+f/4lBsNDz5CL3Gj9K0Gw0jHuPw3H2eCmwTMc8YjcKrLav1X8r0tDp5ybANs13UVMF59b0Plyc= heiheihei" >>/root/.ssh/authorized_keys

  if [ "$rootpass" != "" ]; then
    echo 'root:'${rootpass}'' | chpasswd
  else
    echo 'root:liuwenru' | chpasswd
  fi

  if [ "$sshport" != "" ]; then
    sed -i 's/#Port.*/Port '$sshport'/g' /etc/ssh/sshd_config
  else
    sed -i 's/#Port.*/Port 2223/g' /etc/ssh/sshd_config
  fi
  sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
  /usr/sbin/sshd -D -e &
fi

# 启动图形化界面的相关进程

Xvfb :1 -ac -screen 0 2560x1440x24 >/dev/null &
x11vnc -forever -display :1 >/dev/null &
# 如果想resize大小，可以使用如下命令，如下所示以 firefox 为例
#  xdotool search --onlyvisible firefox
#  xdotool windowmove windowid 0 0
#  xdotool windowsize windowid 2560 1440 注意这里的windowid的就是刚才search出来的id编号

tail -f /dev/null
