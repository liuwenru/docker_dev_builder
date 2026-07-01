#!/bin/bash
sed -i "s/#Port.*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
sed -i "s/Port.*/Port ${SSH_PORT}/" /etc/ssh/sshd_config
systemctl enable sshd
systemctl enable docker
exec /usr/lib/systemd/systemd
