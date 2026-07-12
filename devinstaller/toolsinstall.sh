#!/usr/bin/env bash
# set -euo pipefail
shopt -s expand_aliases
# bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

if [[ $(uname -m) == "x86_64" ]]; then
  cp /opt/devinstaller/bin/tini-static-amd64 /tini
elif [[ $(uname -m) == "aarch64" ]]; then
  cp /opt/devinstaller/bin/tini-static-arm64 /tini
fi
cp /opt/devinstaller/bin/entrypoint.sh /entrypoint.sh
chmod +x /tini 
chmod +x /entrypoint.sh

# install systemd等
if grep -qi ubuntu /etc/os-release; then
  apt-get update && apt-get install -y openssh-server openssh-client sudo systemd sysvinit-utils net-tools iproute2 iputils-ping iptables vim
elif command -v dnf >/dev/null 2>&1; then
  dnf -y --setopt=keepcache=True install openssh-server openssh-clients sudo systemd initscripts net-tools iproute iputils iptables vim
else
  yum -y --setopt=keepcache=1 install openssh-server openssh-clients sudo systemd initscripts net-tools iproute iputils iptables vim
fi

# bash tools

if [[ $SHELL == "/bin/bash" ]]; then set +o history; fi
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
if [[ ! -f /usr/bin/busybox ]]; then downloader /usr/bin/busybox https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/busybox/busybox_$(uname -m) && chmod +x /usr/bin/busybox; fi
if [[ -f /usr/bin/busybox ]]; then chmod +x /usr/bin/busybox && alias tar='busybox tar' && alias unzip='busybox unzip'; fi
if [[ $(uname -m) == "x86_64" ]];then
  downloader /tmp/starship.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/starship/starship-x86_64-unknown-linux-musl.tar.gz
elif [[ $(uname -m) == "aarch64" ]]; then
  downloader /tmp/starship.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/starship/starship-aarch64-unknown-linux-musl.tar.gz
fi
tar -zxvf /tmp/starship.tar.gz -C /usr/bin/
echo 'eval "$(starship init bash)"' >> ~/.bashrc
mkdir -p ~/.config && cat <<'EOF' >~/.config/starship.toml
# ~/.config/starship.toml
"$schema" = 'https://starship.rs/config-schema.json'

# 自定义 prompt 格式，只保留需要的模块
format = """
[$username](bold yellow)[@](white)[$localip](bold cyan) \
[$time](bold green) [$cmd_duration](bold yellow)\
$line_break\
 [$directory](bold blue) ❯ """

add_newline = false

# 登录用户
[username]
show_always = true
format = '[$user]($style)'
style_user = 'bold yellow'
style_root = 'bold red'

# 主机 IP 地址（本地 IP）
[localip]
ssh_only = false
disabled = false
format = '[$localipv4]($style)'
style = 'bold cyan'

# 当前路径
[directory]
format = '[$path]($style)[$read_only]($read_only_style) '
style = 'bold blue'
truncation_length = 3
truncation_symbol = '…/'
use_logical_path = false

# 命令执行时间
[cmd_duration]
min_time = 0          # 所有命令都显示耗时（默认 2000ms 才显示）
format = 'TOOK: [$duration]($style) '
style = 'bold yellow'

# 当前时间
[time]
disabled = false
format = 'TIME: [$time]($style)'
time_format = '%Y-%m-%d-%H:%M:%S'
style = 'bold green'

# 禁用不需要的模块（加速 prompt 渲染）
[git_branch]
disabled = true

[git_status]
disabled = true

[package]
disabled = true
EOF
# if [[ $(uname -m) == "x86_64" ]];then
#   downloader /tmp/fzf.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.64.0-linux_amd64.tar.gz
# elif [[ $(uname -m) == "aarch64" ]]; then
#   downloader /tmp/fzf.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.64.0-linux_arm64.tar.gz 
# fi
# mkdir ~/.fzf
# downloader /tmp/fzfinstall.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/fzf/fzf-0.64.0.tar.gz
# tar --strip-components=1 -zxvf /tmp/fzfinstall.tar.gz -C ~/.fzf/
# tar -zxf /tmp/fzf.tar.gz -C ~/.fzf/bin 
# cd ~/.fzf && ./install --all

if [[ $(uname -m) == "x86_64" ]];then
  downloader /tmp/atuin.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/atuin/atuin-x86_64-unknown-linux-musl.tar.gz
elif [[ $(uname -m) == "aarch64" ]]; then
  downloader /tmp/atuin.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/atuin/atuin-aarch64-unknown-linux-musl.tar.gz 
fi
tar --strip-components=1 -zxvf /tmp/atuin.tar.gz -C /usr/bin/ atuin-$(uname -m)-unknown-linux-musl/atuin && rm -rf /tmp/atuin.tar.gz
downloader /tmp/bash-preexec.sh https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/atuin/bash-preexec.sh && mv /tmp/bash-preexec.sh ~/.bash-preexec.sh && echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >> ~/.bashrc && rm -rf /tmp/bash-preexec.sh
echo 'eval "$(atuin init bash --disable-up-arrow --disable-ai)"' >> ~/.bashrc
mkdir -p ~/.config/atuin && cat <<'EOF' >~/.config/atuin/config.toml
auto_sync = false
sync_address = "https://localhost"
enter_accept = false
EOF
echo "alias ll='ls -lh'" >> ~/.bashrc
source ~/.bashrc
if [[ $SHELL == "/bin/bash" ]];then set -o history; fi



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
downloader /tmp/tools.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/static_tools/$(uname -m)_static_tools.tar.gz && tar -zxvf /tmp/tools.tar.gz -C /usr/local/bin && rm -rf /tmp/tools.tar.gz


if [[ $SHELL == "/bin/bash" ]];then set +o history; fi
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
[[ -f /usr/bin/busybox ]] && { alias tar='/usr/bin/busybox tar'; alias unzip='/usr/bin/busybox unzip'; }
case "$(uname -m)" in x86_64) A=x86_64 ;; aarch64|arm64) A=aarch64 ;; *) A=skip ;; esac
T=/tmp/.xt_$$ && mkdir -p "$T" && cd "$T"
case "$A" in
  x86_64)
    downloader rg.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/ripgrep/ripgrep-15.1.0-x86_64-unknown-linux-musl.tar.gz'
    downloader rc.zip 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rclone/rclone-v1.70.3-linux-amd64.zip'
    downloader du.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/dust/dust-v1.2.4-x86_64-unknown-linux-musl.tar.gz'
    downloader sf.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/sshfs/sshfs-tools-x86_64.tar.gz'
    downloader q.tgz  'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/q/q_0.19.11_linux_amd64.tar.gz'
    downloader rn.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rustnet/rustnet-v1.4.0-x86_64-unknown-linux-musl.tar.gz'
    downloader s2.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/s2sx/s2-linux_amd64.tar.gz'
    downloader jq 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/jq-linux-amd64'
    downloader yq.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/yq_linux_amd64.tar.gz' ;;
  aarch64)
    downloader rg.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/ripgrep/ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz'
    downloader rc.zip 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rclone/rclone-v1.70.3-linux-arm64.zip'
    downloader du.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/dust/dust-v1.2.4-aarch64-unknown-linux-musl.tar.gz'
    downloader sf.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/sshfs/sshfs-tools-aarch64.tar.gz'
    downloader q.tgz  'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/q/q_0.19.11_linux_arm64.tar.gz'
    downloader rn.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rustnet/rustnet-v1.4.0-aarch64-unknown-linux-musl.tar.gz'
    downloader s2.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/s2sx/s2-linux_arm64.tar.gz'
    downloader jq 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/jq-linux-arm64'
    downloader yq.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/yq_linux_arm64.tar.gz' ;;
esac
[[ -f rg.tgz ]] && tar -xzf rg.tgz && find . -type f -name rg       -exec install -m 0755 {} /usr/local/bin/rg \;
[[ -f rc.zip ]] && unzip -q rc.zip && find . -type f -name rclone   -exec install -m 0755 {} /usr/local/bin/rclone \;
[[ -f du.tgz ]] && tar -xzf du.tgz && find . -type f -name dust     -exec install -m 0755 {} /usr/local/bin/dust \;
[[ -f sf.tgz ]] && tar -xzf sf.tgz && for b in sshfs fusermount3 mount.fuse3; do install -m 0755 sshfs-tools-*/$b /usr/local/bin/ 2>/dev/null; done
[[ -f q.tgz  ]] && tar -xzf q.tgz  && find . -type f -name q         -exec install -m 0755 {} /usr/local/bin/q \;
[[ -f rn.tgz ]] && tar -xzf rn.tgz && find . -type f -name rustnet   -exec install -m 0755 {} /usr/local/bin/rustnet \;
[[ -f s2.tgz ]] && tar -xzf s2.tgz && for b in s2c s2d s2sx; do install -m 0755 s2/$b /usr/local/bin/ 2>/dev/null; done
[[ -f jq ]] && install -m 0755 jq /usr/local/bin/jq
[[ -f yq.tgz ]] && tar -xzf yq.tgz && find . -type f -name 'yq_linux_*' -exec install -m 0755 {} /usr/local/bin/yq \;
cd ~ && rm -rf "$T"
if [[ $SHELL == "/bin/bash" ]];then set -o history; fi
