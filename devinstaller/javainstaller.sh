#!/usr/bin/env bash
set -euo pipefail

# ---------- 安装 jabba ----------
[ -n "$BASH_VERSION" ] && set +o history
BASEURL=https://fdoc.epoint.com.cn:3366/tmp/.liuwenru
export JABBA_HOME=${JABBA_HOME:-$HOME/.jabba}
dl() { if command -v curl >/dev/null 2>&1; then curl -fsSLk -o "$1" "$2"; else wget --no-check-certificate -q -O "$1" "$2"; fi; }
case "$(uname -m)" in x86_64|amd64) ARCH=amd64;; aarch64|arm64) ARCH=arm64;; *) ARCH=;; esac
if [ -z "$ARCH" ]; then echo "不支持的架构: $(uname -m)"; else
  mkdir -p "$JABBA_HOME/bin" \
  && dl "$JABBA_HOME/bin/jabba" "$BASEURL/tools/jabba/jabba-0.14.0-linux-$ARCH" \
  && dl "$JABBA_HOME/local-install.sh" "$BASEURL/tools/jabba/local-install.sh" \
  && bash "$JABBA_HOME/local-install.sh" \
  && . "$JABBA_HOME/jabba.sh"
fi
[ -n "$BASH_VERSION" ] && set -o history

# ---------- 用 jabba 从镜像站安装 JDK ----------
JDK_BASEURL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK"
case "$(uname -m)" in
x86_64)
  JDK8="openjdk-8.0.312=tgz+${JDK_BASEURL}/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz"
  JDK11="openjdk-11.0.31=tgz+${JDK_BASEURL}/OpenJDK11U-jdk_x64_linux_hotspot_11.0.31_11.tar.gz"
  JDK17="openjdk-17.0.10=tgz+${JDK_BASEURL}/.openjdk17/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
  JDK21="openjdk-21.0.11=tgz+${JDK_BASEURL}/OpenJDK21U-jdk_x64_linux_hotspot_21.0.11_10.tar.gz"
  ;;
aarch64)
  JDK8="openjdk-8.0.312=tgz+${JDK_BASEURL}/OpenJDK8U-jdk_aarch64_linux_hotspot_8u312b07.tar.gz"
  # 镜像站上 jdk_arm 是 32 位 armhf 的包，aarch64 只有 11.0.13
  JDK11="openjdk-11.0.13=tgz+${JDK_BASEURL}/.openjdk11/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.13_8.tar.gz"
  JDK17="openjdk-17.0.10=tgz+${JDK_BASEURL}/.openjdk17/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.10_7.tar.gz"
  JDK21="openjdk-21.0.11=tgz+${JDK_BASEURL}/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.11_10.tar.gz"
  ;;
*)
  echo "Unsupported architecture: $(uname -m)" >&2
  exit 1
  ;;
esac

# 失败重试 3 次，raw.githubusercontent.com 走代理偶尔会 SSL 握手失败
retry() {
  local attempt
  for attempt in 1 2 3; do
    "$@" && return 0
    echo ">>> 第 ${attempt}/3 次失败: $*" >&2
    sleep 5
  done
  return 1
}

install_jdk() {
  local version="$1" spec="$2"
  local name="${spec%%=*}"

  echo ">>> Installing ${name} (${spec#*=})"
  retry jabba install "${spec}"

  # 保持原来的 /opt/openjdkN、/usr/local/jdkN 路径不变，指向 jabba 的安装目录
  ln -sfn "$(jabba which "${name}")" "/opt/openjdk${version}"
  ln -sfn "/opt/openjdk${version}" "/usr/local/jdk${version}"

  echo ">>> ${name} installed at $(jabba which "${name}")"
}

install_jdk 8 "${JDK8}"
install_jdk 11 "${JDK11}"
install_jdk 17 "${JDK17}"
install_jdk 21 "${JDK21}"

jabba alias default "${JDK21%%=*}"

echo "All JDKs installed successfully."

ln -s /opt/openjdk21 /usr/local/jdk

antdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/apache-ant-1.10.12-bin.tar.gz"
retry curl -fkL -o /tmp/ant.tar.gz ${antdownloadurl}
mkdir /opt/ant
tar -zxf /tmp/ant.tar.gz --strip-components 1 -C /opt/ant/
ln -s /opt/ant /usr/local/ant
rm -rf /tmp/ant.tar.gz

mavendownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/apache-maven-3.8.6-bin.tar.gz"
retry curl -fkL -o /tmp/maven.tar.gz ${mavendownloadurl}
mkdir /opt/maven
tar -zxf /tmp/maven.tar.gz --strip-components 1 -C /opt/maven/
ln -s /opt/maven /usr/local/maven
rm -rf /tmp/maven.tar.gz

mkdir /root/.m2
retry curl -fkL -o /root/.m2/settings.xml https://raw.githubusercontent.com/liuwenru/mymacprofile/master/maven/settings.xml
retry curl -fkL -o /root/.m2/jvm.config https://raw.githubusercontent.com/liuwenru/mymacprofile/master/maven/jvm.config
