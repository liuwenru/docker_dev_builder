#/bin/bash

test -f /etc/ssh/ssh_host_ecdsa_key || /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -C '' -N ''
test -f /etc/ssh/ssh_host_rsa_key || /usr/bin/ssh-keygen -q -t rsa -f /etc/ssh/ssh_host_rsa_key -C '' -N ''
test -f /etc/ssh/ssh_host_ed25519_key || /usr/bin/ssh-keygen -q -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -C '' -N ''
test -f /root/.ssh/id_rsa || /usr/bin/ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
test -f /root/.ssh/id_rsa.pub || ssh-keygen -y -t rsa -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub
test -f /root/.ssh/authorized_keys || /usr/bin/cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys

echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC91aL7mwiy81Pps8Yj85P1tTCO/vqrZO+fUvHeIbQ6gzRrxnMy1mL1oRwRdzUoOKraw8tVEssDCqsY/XNIwseflhMyMUt9PwdSX9cBo4lUy74SRIyTmZqbghH/uFzg0vvsneIzYWUSNE2we5i4agsWW4IqCfOPKaw4qvM0i7cASeo1BF7a7p4xMOug6dYiGxJY4EmGS9MbkLQ/5mlrLDVK6aawLZyuxIZ6cR6S0zoqHJTj+F67Zld3m/AWljHNyCjqgua+zqSfYtVS1D45omjPC6g8KQkvkBJGg4MR6VhhvoNyB4/TZcQrdmiRSS0RQpr6qoFQHHmzQw7xhjQaaLUj ijarvis@ijarvisMacBookPro.local" >> /root/.ssh/authorized_keys

if [[ $rootpass != "" ]];then
    echo $rootpass | passwd root --stdin
else
    echo "liuwenru" | passwd root --stdin
fi

if [[ $sshport != "" ]];then
    sed -i 's/#Port.*/Port '$sshport'/g' /etc/ssh/sshd_config
else
    sed -i 's/#Port.*/Port 2223/g' /etc/ssh/sshd_config
fi
sed -i 's/#UseDNS.*/UseDNS no/g' /etc/ssh/sshd_config
/usr/sbin/sshd -D -e

