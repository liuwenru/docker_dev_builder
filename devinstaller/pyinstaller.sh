#!/usr/bin/env bash
# ============================================================
# Python 多版本编译安装函数库
# 使用: source install_python.sh
#       install_python 3.12.11
#       install_python 3.13.5
# ============================  ================================
set -euo pipefail

# ---------- 支持的版本 ----------
PYTHON_VERSIONS=("3.12.11" "3.13.5" "3.14.6")
declare -A PYTHON_TARBALL_URLS=(
  ["3.12.11"]="https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.12.11.tgz"
  ["3.13.5"]="https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.13.5.tgz"
  ["3.14.6"]="https://fdoc.epoint.com.cn:3366/Aibuild/Python-3.14.6.tgz"
)

# ---------- 并行构建配置 ----------
PARALLEL_JOBS="${PARALLEL_JOBS:-$(( $(nproc) < ${#PYTHON_VERSIONS[@]} ? $(nproc) : ${#PYTHON_VERSIONS[@]} ))}"
PYTHON_INSTALL_LOG_DIR="${PYTHON_INSTALL_LOG_DIR:-/tmp}"

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
  jobs=$(( $(nproc) / PARALLEL_JOBS ))
  (( jobs < 1 )) && jobs=1
  tarball="${build_dir}/python.tgz"

  _check_env

  # 强制重编: 永远清理旧 prefix, 不做时间戳判断
  if [[ -d "${prefix}" ]]; then
    _log "删除旧的 ${prefix}, 强制重编 ${version}"
    rm -rf "${prefix}"
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
  make -j"${jobs}" PROFILE_TASK='-m test --pgo -j0'

  # 4. 安装
  _log "make altinstall"
  make altinstall
  cd / && rm -rf "${build_dir}"

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

# ---------- 单版本带前缀输出 + 日志落盘 ----------
_install_one_with_prefix() {
  # 后台任务(&)默认忽略 SIGINT，会导致 PGO 阶段的 test_generators 失败
  trap - INT QUIT
  local v="$1"
  local log="${PYTHON_INSTALL_LOG_DIR}/pyinstall-${v}.log"
  : > "${log}"
  install_python "${v}" 2>&1 | \
  while IFS= read -r line; do
    printf '[%s] %s\n' "${v}" "${line}"
  done | tee -a "${log}"
  return "${PIPESTATUS[0]}"
}

# ---------- 批量安装所有支持的版本（并行） ----------
install_all_pythons() {
  local max="${PARALLEL_JOBS}"
  local pids=() v_for_pid=() failed=()

  for v in "${PYTHON_VERSIONS[@]}"; do
    _install_one_with_prefix "${v}" &
    pids+=($!)
    v_for_pid+=("${v}")
    if (( ${#pids[@]} >= max )); then
      wait "${pids[0]}" || failed+=("${v_for_pid[0]}")
      pids=("${pids[@]:1}")
      v_for_pid=("${v_for_pid[@]:1}")
    fi
  done

  for i in "${!pids[@]}"; do
    wait "${pids[$i]}" || failed+=("${v_for_pid[$i]}")
  done

  echo ""
  echo "============================================"
  echo " Python 安装汇总"
  echo "============================================"
  for v in "${PYTHON_VERSIONS[@]}"; do
    if [[ " ${failed[*]} " == *" ${v} "* ]]; then
      echo " [FAIL] ${v}  日志: ${PYTHON_INSTALL_LOG_DIR}/pyinstall-${v}.log"
    else
      echo " [ OK ] ${v}"
    fi
  done
  echo "============================================"

  if (( ${#failed[@]} > 0 )); then
    return 1
  fi
}

# ---------- uv 安装 (带重试) ----------
_install_uv_with_retry() {
  local max_attempts=3
  local attempt=1
  while (( attempt <= max_attempts )); do
    _log "下载并安装 uv (第 ${attempt}/${max_attempts} 次): https://astral.sh/uv/install.sh"
    if wget --no-check-certificate  -qO- https://astral.sh/uv/install.sh | sh; then
      _log "uv 安装完成"
      return 0
    fi
    _log "uv 安装失败, 准备重试..."
    attempt=$((attempt + 1))
    sleep 5
  done
  _die "uv 下载安装失败, 已重试 ${max_attempts} 次"
}

# ---------- 直接执行入口 ----------
# 如果是 source 进来, 不会执行下面; 直接跑脚本则装所有版本
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  _install_uv_with_retry
  if [[ $# -eq 0 ]]; then
    install_all_pythons
  else
    install_python "$1"
  fi

  
fi
