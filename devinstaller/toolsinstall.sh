#!/usr/bin/env bash
# set -euo pipefail

# bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

if [[ $(uname -m) == "x86_64" ]]; then
  cp /opt/devinstaller/bin/tini-static-amd64 /tini
elif [[ $(uname -m) == "aarch64" ]]; then
  cp /opt/devinstaller/bin/tini-static-arm64 /tini
fi
chmod +x /tini

# install systemd等
if grep -qi ubuntu /etc/os-release; then
  apt-get update && apt-get install -y openssh-server openssh-client sudo systemd sysvinit-utils net-tools iproute2 iputils-ping iptables vim
elif command -v dnf >/dev/null 2>&1; then
  dnf -y install openssh-server openssh-clients sudo systemd initscripts net-tools iproute iputils iptables vim
else
  yum -y install openssh-server openssh-clients sudo systemd initscripts net-tools iproute iputils iptables vim
fi

# bash tools

curl -k -L -o /tmp/bashit.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/bashit/bashit-v3.0.3.tar.gz
mkdir ~/.bash_it
tar -zxvf /tmp/bashit.tar.gz --strip-components 1 -C ~/.bash_it
~/.bash_it/install.sh --silent --append-to-config
if [[ $(uname -m) == "x86_64" ]]; then
  curl -k -L -o /tmp/fzf.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.64.0-linux_amd64.tar.gz
elif [[ $(uname -m) == "aarch64" ]]; then
  curl -k -L -o /tmp/fzf.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.64.0-linux_arm64.tar.gz
fi
mkdir ~/.fzf
curl -k -L -o /tmp/fzfinstall.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.64.0.tar.gz
tar --strip-components=1 -zxvf /tmp/fzfinstall.tar.gz -C ~/.fzf/
tar -zxf /tmp/fzf.tar.gz -C ~/.fzf/bin
cd ~/.fzf && ./install --all
echo "alias ll='ls -lh'" >>~/.bashrc

sed -i '/export BASH_IT="\/root\/.bash_it"/a export THEME_SHOW_CLOCK_CHAR=false' ~/.bashrc
sed -i 's/export SCM_CHECK=true/export SCM_CHECK=false/g' ~/.bashrc
source ~/.bashrc
if [[ $SHELL == "/bin/bash" ]]; then set -o history; fi

# install git
curl -k -L -o /tmp/git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.44.0.tar.gz

mkdir /tmp/git && cd /tmp/git && tar --strip-components=1 -zxf /tmp/git.tar.gz -C /tmp/git
./configure --prefix=/opt/git2.44 && make -j$(nproc) && make install && ln -s /opt/git2.44 /usr/local/git
curl -k -L -o /root/.gitconfig https://raw.githubusercontent.com/liuwenru/mymacprofile/master/git/gitconfig
curl -k -L -o /root/.gitignore_global https://raw.githubusercontent.com/liuwenru/mymacprofile/master/git/gitignore_global

# install static and new static tools
shopt -s expand_aliases
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
if [[ ! -f /usr/bin/busybox ]]; then downloader /usr/bin/busybox https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/busybox/busybox_$(uname -m) && chmod +x /usr/bin/busybox; fi
if [[ -f /usr/bin/busybox ]]; then chmod +x /usr/bin/busybox && alias tar='busybox tar' && alias unzip='busybox unzip'; fi
downloader /tmp/tools.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/$(uname -m)_static_tools.tar.gz && tar -zxvf /tmp/tools.tar.gz -C /usr/local/bin && rm -rf /tmp/tools.tar.gz

if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
[[ -f /usr/bin/busybox ]] && {
  alias tar='/usr/bin/busybox tar'
  alias unzip='/usr/bin/busybox unzip'
}
case "$(uname -m)" in x86_64) A=x86_64 ;; aarch64 | arm64) A=aarch64 ;; *) A=skip ;; esac
T=/tmp/.xt_$$ && mkdir -p "$T" && cd "$T"
case "$A" in
x86_64)
  downloader rg.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/ripgrep/ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz'
  downloader rc.zip 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rclone/rclone-v1.70.3-linux-amd64.zip'
  downloader du.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/dust/dust-v1.2.4-x86_64-unknown-linux-musl.tar.gz'
  downloader sf.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/sshfs/sshfs-tools-x86_64.tar.gz'
  downloader q.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/q/q_0.19.11_linux_amd64.tar.gz'
  downloader rn.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rustnet/rustnet-v1.4.0-x86_64-unknown-linux-musl.tar.gz'
  ;;
aarch64)
  downloader rg.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/ripgrep/ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz'
  downloader rc.zip 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rclone/rclone-v1.70.3-linux-arm64.zip'
  downloader du.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/dust/dust-v1.2.4-aarch64-unknown-linux-musl.tar.gz'
  downloader sf.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/sshfs/sshfs-tools-aarch64.tar.gz'
  downloader q.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/q/q_0.19.11_linux_arm64.tar.gz'
  downloader rn.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rustnet/rustnet-v1.4.0-aarch64-unknown-linux-musl.tar.gz'
  ;;
esac
[[ -f rg.tgz ]] && tar -xzf rg.tgz && find . -type f -name rg -exec install -m 0755 {} /usr/local/bin/rg \;
[[ -f rc.zip ]] && unzip -q rc.zip && find . -type f -name rclone -exec install -m 0755 {} /usr/local/bin/rclone \;
[[ -f du.tgz ]] && tar -xzf du.tgz && find . -type f -name dust -exec install -m 0755 {} /usr/local/bin/dust \;
[[ -f sf.tgz ]] && tar -xzf sf.tgz && for b in sshfs fusermount3 mount.fuse3; do install -m 0755 sshfs-tools-*/$b /usr/local/bin/ 2>/dev/null; done
[[ -f q.tgz ]] && tar -xzf q.tgz && find . -type f -name q -exec install -m 0755 {} /usr/local/bin/q \;
[[ -f rn.tgz ]] && tar -xzf rn.tgz && find . -type f -name rustnet -exec install -m 0755 {} /usr/local/bin/rustnet \;
cd ~ && rm -rf "$T"
