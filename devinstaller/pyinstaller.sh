#!/usr/bin/env bash
# ============================================================
# Python 多版本编译安装函数库
# 使用: source install_python.sh
#       install_python 3.12.11
#       install_python 3.13.5
# ============================  ================================
# set -euo pipefail

# ---------- 支持的版本 ----------
PYTHON_VERSIONS=("3.12.11" "3.13.5" "3.14.6")
declare -A PYTHON_TARBALL_URLS=(
  ["3.12.11"]="https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.12.11.tgz"
  ["3.13.5"]="https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.13.5.tgz"
  ["3.14.6"]="https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.14.6.tgz"
)

# ---------- 工具函数 ----------
_log() { echo ">>> $*"; }
_die() {
  echo "ERROR: $*" >&2
  exit 1
}

_check_env() {
  [[ $EUID -eq 0 ]] || _die "请用 root 运行"
  for cmd in gcc make tar curl; do
    command -v "$cmd" >/dev/null 2>&1 || _die "缺少依赖: $cmd"
  done
}

# ---------- 核心安装函数 ----------
install_python() {
  local version="${1:?用法: install_python <version>, 例如 install_python 3.12.11}"
  local url tarball build_dir prefix short_ver jobs

  # 校验版本是否支持
  if [[ -z "${PYTHON_TARBALL_URLS[$version]+x}" ]]; then
    _die "不支持的版本: ${version}, 支持: ${PYTHON_VERSIONS[*]}"
  fi

  url="${PYTHON_TARBALL_URLS[$version]}"
  short_ver="$(echo "${version}" | cut -d. -f1,2)" # 3.12
  prefix="/opt/python${short_ver//./}"             # /opt/python312
  build_dir="/tmp/python-build-${version}"
  jobs="$(nproc)"
  tarball="${build_dir}/python.tgz"

  _check_env

  # 已装则跳过 (可注释掉强制重装)
  if [[ -x "${prefix}/bin/python${short_ver}" ]]; then
    _log "${version} 已安装在 ${prefix}, 跳过 (删掉目录可强制重装)"
    "${prefix}/bin/python${short_ver}" --version
    return 0
  fi

  # 1. 准备源码
  _log "清理并创建构建目录: ${build_dir}"
  rm -rf "${build_dir}"
  mkdir -p "${build_dir}"
  cd "${build_dir}"

  _log "下载 ${version}: ${url}"
  curl -fSL --retry 3 -o "${tarball}" "${url}"
  [[ -s "${tarball}" ]] || _die "下载失败或文件为空"

  _log "解压源码"
  tar --strip-components=1 -xzf "${tarball}"
  rm -f "${tarball}"

  # 2. 配置
  _log "./configure (prefix=${prefix})"
  ./configure \
    --prefix="${prefix}" \
    --enable-optimizations \
    --with-lto \
    --enable-shared \
    --with-ensurepip=install

  # 3. 编译
  _log "make -j${jobs}"
  make -j"${jobs}"

  # 4. 安装
  _log "make altinstall"
  make altinstall

  # 5. 注册动态库
  _log "注册 ${prefix}/lib 到 ldconfig"
  echo "${prefix}/lib" >"/etc/ld.so.conf.d/python${short_ver//./}.conf"
  ldconfig

  # 6. 软链到 PATH
  _log "创建符号链接到 /usr/local/bin"
  ln -sf "${prefix}/bin/python${short_ver}" "/usr/local/bin/python${short_ver}"
  ln -sf "${prefix}/bin/pip${short_ver}" "/usr/local/bin/pip${short_ver}"

  # 7. 验证
  echo ""
  echo "============================================"
  echo " Python ${version} 安装完成 -> ${prefix}"
  echo "============================================"
  "${prefix}/bin/python${short_ver}" --version
  "${prefix}/bin/python${short_ver}" -m pip --version
  echo ""
  echo "使用: python${short_ver} / pip${short_ver}"
}

# ---------- 批量安装所有支持的版本 ----------
install_all_pythons() {
  for v in "${PYTHON_VERSIONS[@]}"; do
    _log "========== 安装 ${v} =========="
    install_python "${v}"
  done
}

# ---------- 直接执行入口 ----------
# 如果是 source 进来, 不会执行下面; 直接跑脚本则装所有版本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  if [[ $# -eq 0 ]]; then
    install_all_pythons
  else
    install_python "$1"
  fi
fi

wget -qO- https://astral.sh/uv/install.sh | sh
