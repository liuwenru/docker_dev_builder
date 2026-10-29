#!/usr/bin/env bash
# ============================================================
# 使用 uv 从镜像站安装 python-build-standalone 预编译的多版本 Python
# python3.x / python3 / python 都放在 /usr/local/bin，非交互 shell 也能直接用
# 原来的源码编译方式保留在 pyinstaller_compile.sh
# ============================================================
set -euo pipefail

# uv 的版本决定去镜像站哪个 release 目录下载（0.13.6 -> 20261026），
# 升级 uv 之前要先把对应 release 同步到镜像站
UV_VERSION="0.13.6"
PYTHON_VERSIONS=("3.11" "3.12" "3.13" "3.14" "3.15")
PYTHON_DEFAULT="${PYTHON_DEFAULT:-3.12}"

PYTHON_MIRROR="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/astral-sh-python-build-standalone/"

export UV_INSTALL_DIR=/usr/local/bin
export UV_NO_MODIFY_PATH=1
export UV_PYTHON_INSTALL_MIRROR="${PYTHON_MIRROR}"
export UV_PYTHON_BIN_DIR=/usr/local/bin
export UV_INSECURE_HOST=fdoc.epoint.com.cn
export PATH="/usr/local/bin:${PATH}"

_log() { echo ">>> $*"; }
_die() {
  echo "ERROR: $*" >&2
  exit 1
}

# ---------- uv 安装 (带重试) ----------
_install_uv_with_retry() {
  local max_attempts=3
  local attempt=1
  while ((attempt <= max_attempts)); do
    _log "下载并安装 uv ${UV_VERSION} (第 ${attempt}/${max_attempts} 次)"
    if curl -fsSL "https://astral.sh/uv/${UV_VERSION}/install.sh" | sh; then
      _log "uv 安装完成: $(uv --version)"
      return 0
    fi
    _log "uv 安装失败, 准备重试..."
    attempt=$((attempt + 1))
    sleep 5
  done
  _die "uv 下载安装失败, 已重试 ${max_attempts} 次"
}

_install_uv_with_retry

_log "安装 Python: ${PYTHON_VERSIONS[*]}"
uv python install "${PYTHON_VERSIONS[@]}"

_log "设置默认 Python ${PYTHON_DEFAULT} (python / python3)"
uv python install --default --preview-features python-install-default "${PYTHON_DEFAULT}"
uv python pin --global "${PYTHON_DEFAULT}"

# 登录 shell 里同样生效：之后用 uv 装新版本也走镜像站
cat >/etc/profile.d/uv-python.sh <<EOF
export UV_PYTHON_INSTALL_MIRROR="${PYTHON_MIRROR}"
export UV_PYTHON_BIN_DIR=/usr/local/bin
export UV_INSECURE_HOST=fdoc.epoint.com.cn
case ":\${PATH}:" in
*:/usr/local/bin:*) ;;
*) export PATH="/usr/local/bin:\${PATH}" ;;
esac
EOF

for v in "${PYTHON_VERSIONS[@]}"; do
  "/usr/local/bin/python${v}" --version
done
_log "python3 -> $(python3 --version)"
