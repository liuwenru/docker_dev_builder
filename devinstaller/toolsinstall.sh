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
shopt -s expand_aliases
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
if [[ ! -f /usr/bin/busybox ]]; then downloader /usr/bin/busybox https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/busybox/busybox_$(uname -m) && chmod +x /usr/bin/busybox; fi
if [[ -f /usr/bin/busybox ]]; then chmod +x /usr/bin/busybox && alias tar='busybox tar' && alias unzip='busybox unzip'; fi
if [[ $(uname -m) == "x86_64" ]]; then
  downloader /tmp/starship.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/starship/starship-x86_64-unknown-linux-musl.tar.gz
elif [[ $(uname -m) == "aarch64" ]]; then
  downloader /tmp/starship.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/starship/starship-aarch64-unknown-linux-musl.tar.gz
fi
tar -zxvf /tmp/starship.tar.gz -C /usr/bin/
echo 'eval "$(starship init bash)"' >>~/.bashrc
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

# 主机 IP 地址（仅 IPv4 数字地址，不做 DNS 解析；用于标识当前登录的机器）
[localip]
disabled = false
ssh_only = false
format = '[$localipv4]($style)'
style = 'bold cyan'

# 当前路径
[directory]
format = '[$path]($style)[$read_only]($read_only_style) '
style = 'bold blue'
truncation_length = 3
truncation_symbol = '…/'

# 命令执行时间 - 优化：仅在 >= 2s 时显示，减少每次 prompt 的格式计算
[cmd_duration]
min_time = 2000       # 仅显示执行 ≥ 2s 的命令耗时（默认 2000ms）
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

# 进一步禁用：每个 prompt 都不需要扫描的开销模块
[nodejs]
disabled = true

[python]
disabled = true

[java]
disabled = true

[ruby]
disabled = true

[rust]
disabled = true

[php]
disabled = true

[golang]
disabled = true

[nix_shell]
disabled = true

[aws]
disabled = true

[gcloud]
disabled = true

[memory_usage]
disabled = true

[docker_context]
disabled = true

[kubernetes]
disabled = true

[terraform]
disabled = true

[conda]
disabled = true

[env_var]
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

if [[ $(uname -m) == "x86_64" ]]; then
  downloader /tmp/atuin.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/atuin/atuin-x86_64-unknown-linux-musl.tar.gz
elif [[ $(uname -m) == "aarch64" ]]; then
  downloader /tmp/atuin.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/atuin/atuin-aarch64-unknown-linux-musl.tar.gz
fi
tar --strip-components=1 -zxvf /tmp/atuin.tar.gz -C /usr/bin/ atuin-$(uname -m)-unknown-linux-musl/atuin && rm -rf /tmp/atuin.tar.gz
downloader /tmp/bash-preexec.sh https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/atuin/bash-preexec.sh && mv /tmp/bash-preexec.sh ~/.bash-preexec.sh && echo '[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh' >>~/.bashrc && rm -rf /tmp/bash-preexec.sh
echo 'eval "$(atuin init bash --disable-up-arrow --disable-ai)"' >>~/.bashrc
mkdir -p ~/.config/atuin && cat <<'EOF' >~/.config/atuin/config.toml
## atuin 配置

## 关闭启动时的 update check（你不想看到升级提示，且当前 sync_address 是 localhost 根本走不通）
update_check = false

## sync_address 仍是 https://localhost（用户未配置远程同步服务器），所以 auto_sync 必须保持 false
auto_sync = false
sync_address = "https://localhost"

## Enter 直接执行选中的历史命令（与大部分人习惯一致；Tab 仍可编辑）
enter_accept = true

## 同步/网络超时调短，避免请求 localhost:443 时挂 5 秒
network_connect_timeout = 2
network_timeout = 5

## SQLite 本地写超时（默认 5s）
local_timeout = 5

## TUI 更安静：Ctrl-R 弹出搜索面板时计时器不实时跳动、减少闪动
prefers_reduced_motion = true

## 时区（默认 local，可按需改为 "+8" 这种 UTC 偏移，让历史时间戳显示更稳）
# timezone = "local"

## 日期格式（us = MM/DD，uk = DD/MM）
# dialect = "us"

## 搜索模式（prefix | fulltext | fuzzy | skim），fuzzy 适合多数场景
# search_mode = "fuzzy"

## 默认过滤模式（global | host | session | session-preload | directory | workspace）
## 多机用户建议 host；单机用户保持 global
# filter_mode = "global"

## 搜索 UI 风格（auto | full | compact）
# style = "auto"

## 长命令预览（避免被截断看不清）
show_preview = true
max_preview_height = 4

## 在列表里显示数字快捷键（1-9 直接选中）
show_numeric_shortcuts = true

## Ctrl-R 搜索面板的列：时长 + 相对时间 + 主机 + 命令（多机场景下 host 列很有用）
# columns = ["duration", "time", "host", "command"]

## ---- 安全：黑名单正则（不会被写入 history）----
## 默认已经过滤 AWS key / GitHub PAT / Slack token / Stripe key
secrets_filter = true

## 额外想过滤的（按需开启）
# history_filter = [
#   "^rm -rf /",
#   "password\\s*=",
#   "BEGIN .* PRIVATE KEY",
# ]

## ---- stats 统计：让 stats 子命令更有意义 ----
[stats]
## 这些命令的子命令会单独统计（apt install vs apt update）
common_subcommands = [
  "apt", "cargo", "dnf", "docker", "git", "go",
  "kubectl", "npm", "pnpm", "podman", "systemctl",
  "tmux", "yarn",
]
## 统计时剥掉的前缀
common_prefix = ["sudo"]
## 完全不计入统计
ignored_commands = ["ls", "cd", "ll", "pwd", "exit"]

## ---- 同步（当前未启用）----
[sync]
records = true

## ---- 主题（可选）----
[theme]
# name = "autumn"

## ---- 搜索过滤顺序（可选）----
[search]
## 默认 ["global", "host", "session", "session-preload", "workspace", "directory"]
## 多机用户可改为 host 优先
# filters = ["host", "global", "session", "session-preload", "directory"]

[daemon]
## 启用 daemon：每条命令回车时不再 fork atuin 进程，走 Unix socket IPC
## 期望收益：单次 10-30ms → 1-3ms
enabled = true
autostart = true
## daemon 周期同步频率（秒）；sync_address 是 localhost 时不会真正同步
sync_frequency = 300
socket_path = "~/.local/share/atuin/atuin.sock"
pidfile_path = "~/.local/share/atuin/atuin-daemon.pid"

EOF
echo "alias ll='ls -lh'" >>~/.bashrc
source ~/.bashrc
if [[ $SHELL == "/bin/bash" ]]; then set -o history; fi

# install git
curl -k -L -o /tmp/git.tar.gz https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.44.0.tar.gz

mkdir /tmp/git && cd /tmp/git && tar --strip-components=1 -zxf /tmp/git.tar.gz -C /tmp/git
./configure --prefix=/opt/git2.44 && make -j$(nproc) && make install && ln -s /opt/git2.44 /usr/local/git
cd / && rm -rf /tmp/git /tmp/git.tar.gz
curl -k -L -o /root/.gitconfig https://raw.githubusercontent.com/liuwenru/mymacprofile/master/git/gitconfig
curl -k -L -o /root/.gitignore_global https://raw.githubusercontent.com/liuwenru/mymacprofile/master/git/gitignore_global

# install static and new static tools
shopt -s expand_aliases
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
if [[ ! -f /usr/bin/busybox ]]; then downloader /usr/bin/busybox https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/busybox/busybox_$(uname -m) && chmod +x /usr/bin/busybox; fi
if [[ -f /usr/bin/busybox ]]; then chmod +x /usr/bin/busybox && alias tar='busybox tar' && alias unzip='busybox unzip'; fi
downloader /tmp/tools.tar.gz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/static_tools/$(uname -m)_static_tools.tar.gz && tar -zxvf /tmp/tools.tar.gz -C /usr/local/bin && rm -rf /tmp/tools.tar.gz

if [[ $SHELL == "/bin/bash" ]]; then set +o history; fi
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
  downloader s2.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/s2sx/s2-linux_amd64.tar.gz'
  downloader jq 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/jq-linux-amd64'
  downloader yq.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/yq_linux_amd64.tar.gz'
  ;;
aarch64)
  downloader rg.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/ripgrep/ripgrep-15.1.0-aarch64-unknown-linux-gnu.tar.gz'
  downloader rc.zip 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rclone/rclone-v1.70.3-linux-arm64.zip'
  downloader du.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/dust/dust-v1.2.4-aarch64-unknown-linux-musl.tar.gz'
  downloader sf.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/sshfs/sshfs-tools-aarch64.tar.gz'
  downloader q.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/q/q_0.19.11_linux_arm64.tar.gz'
  downloader rn.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/rustnet/rustnet-v1.4.0-aarch64-unknown-linux-musl.tar.gz'
  downloader s2.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/s2sx/s2-linux_arm64.tar.gz'
  downloader jq 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/jq-linux-arm64'
  downloader yq.tgz 'https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/clieditortools/yq_linux_arm64.tar.gz'
  ;;
esac
[[ -f rg.tgz ]] && tar -xzf rg.tgz && find . -type f -name rg -exec install -m 0755 {} /usr/local/bin/rg \;
[[ -f rc.zip ]] && unzip -q rc.zip && find . -type f -name rclone -exec install -m 0755 {} /usr/local/bin/rclone \;
[[ -f du.tgz ]] && tar -xzf du.tgz && find . -type f -name dust -exec install -m 0755 {} /usr/local/bin/dust \;
[[ -f sf.tgz ]] && tar -xzf sf.tgz && for b in sshfs fusermount3 mount.fuse3; do install -m 0755 sshfs-tools-*/$b /usr/local/bin/ 2>/dev/null; done
[[ -f q.tgz ]] && tar -xzf q.tgz && find . -type f -name q -exec install -m 0755 {} /usr/local/bin/q \;
[[ -f rn.tgz ]] && tar -xzf rn.tgz && find . -type f -name rustnet -exec install -m 0755 {} /usr/local/bin/rustnet \;
[[ -f s2.tgz ]] && tar -xzf s2.tgz && for b in s2c s2d s2sx; do install -m 0755 $b /usr/local/bin/ 2>/dev/null; done
[[ -f jq ]] && install -m 0755 jq /usr/local/bin/jq
[[ -f yq.tgz ]] && tar -xzf yq.tgz && find . -type f -name 'yq_linux_*' -exec install -m 0755 {} /usr/local/bin/yq \;
cd ~ && rm -rf "$T"
if [[ $SHELL == "/bin/bash" ]]; then set -o history; fi

#  install bash completions

if [[ $SHELL == "/bin/bash" ]]; then
  set +o history
  shopt -s expand_aliases
fi
if command -v curl >/dev/null 2>&1; then alias downloader='curl -k -L -o'; fi
if command -v wget >/dev/null 2>&1; then alias downloader='wget --no-check-certificate -q -O '; fi
[[ -f /usr/bin/busybox ]] && {
  alias tar='/usr/bin/busybox tar'
  alias unzip='/usr/bin/busybox unzip'
}
BASEURL="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/"
case "$(uname -m)" in x86_64) A=x86_64 ;; aarch64 | arm64) A=aarch64 ;; *) A=skip ;; esac
T=$(mktemp -d /tmp/.xt_XXXXXX) && cd "$T"
case "$A" in
x86_64)
  downloader bcom.tgz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/bash-completion-lite/bash-completion-lite.tar.gz
  ;;
aarch64)
  downloader bcom.tgz https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/tools/bash-completion-lite/bash-completion-lite.tar.gz
  ;;
esac
[[ -f bcom.tgz ]] && rm -rf "$HOME/.local/share/bash-completion"
mkdir -p "$HOME/.local/share/bash-completion"
[[ -f bcom.tgz ]] && tar --strip-components=1 -xzf bcom.tgz -C $HOME/.local/share/bash-completion/
cd ~ && rm -rf "$T"
printf '\n'
printf '\033[1;33m[ACTION]\033[0m 请执行以下命令，使补全功能在当前 Shell 中生效：\n\n'
printf '  \033[1;36msource /root/.local/share/bash-completion/init.bash\033[0m\n\n'
if [[ $SHELL == "/bin/bash" ]]; then set -o history; fi

# 补全只对交互 shell 有用（init.bash 遇到非交互会直接 return），所以写 ~/.bashrc，不写 /etc/devenv.sh
bashrc_line='[ -f /root/.local/share/bash-completion/init.bash ] && source /root/.local/share/bash-completion/init.bash'
grep -qxF "$bashrc_line" ~/.bashrc 2>/dev/null || echo "$bashrc_line" >>~/.bashrc
