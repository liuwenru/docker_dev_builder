#!/usr/bin/env bash
set -euo pipefail

ARCH=$(uname -m)
case "${ARCH}" in
x86_64)
  JDK8_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz"
  JDK11_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK11U-jdk_x64_linux_hotspot_11.0.31_11.tar.gz"
  JDK17_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/.openjdk17/OpenJDK17U-jdk_x64_linux_hotspot_17.0.10_7.tar.gz"
  JDK21_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK21U-jdk_x64_linux_hotspot_21.0.11_10.tar.gz"
  ;;
aarch64)
  JDK8_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK8U-jdk_aarch64_linux_hotspot_8u312b07.tar.gz"
  # 镜像站上 jdk_arm 是 32 位 armhf 的包，aarch64 只有 11.0.13
  JDK11_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/.openjdk11/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.13_8.tar.gz"
  JDK17_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/.openjdk17/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.10_7.tar.gz"
  JDK21_URL="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK21U-jdk_aarch64_linux_hotspot_21.0.11_10.tar.gz"
  ;;
*)
  echo "Unsupported architecture: ${ARCH}" >&2
  exit 1
  ;;
esac

install_jdk() {
  local version="$1" url="$2"
  local dest="/opt/openjdk${version}"
  local tmp
  tmp=$(mktemp -d)
  trap "rm -rf '${tmp}'" RETURN

  echo ">>> Installing OpenJDK ${version} from ${url}"
  curl -fsSL --connect-timeout 15 --max-time 600 -k -L \
    -o "${tmp}/jdk.tar.gz" "${url}"

  mkdir -p "${dest}"
  tar -xzf "${tmp}/jdk.tar.gz" --strip-components 1 -C "${dest}/"

  # 强制重建软链（如果已存在就替换）
  ln -sfn "/opt/openjdk${version}" "/usr/local/jdk${version}"

  echo ">>> OpenJDK ${version} installed at ${dest}"
}

install_jdk 8 "${JDK8_URL}"
install_jdk 11 "${JDK11_URL}"
install_jdk 17 "${JDK17_URL}"
install_jdk 21 "${JDK21_URL}"

echo "All JDKs installed successfully."

ln -s /opt/openjdk21 /usr/local/jdk

antdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/apache-ant-1.10.12-bin.tar.gz"
curl -k -L -o /tmp/ant.tar.gz ${antdownloadurl}
mkdir /opt/ant
tar -zxf /tmp/ant.tar.gz --strip-components 1 -C /opt/ant/
ln -s /opt/ant /usr/local/ant
rm -rf /tmp/ant.tar.gz

mavendownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/apache-maven-3.8.6-bin.tar.gz"
curl -k -L -o /tmp/maven.tar.gz ${mavendownloadurl}
mkdir /opt/maven
tar -zxf /tmp/maven.tar.gz --strip-components 1 -C /opt/maven/
ln -s /opt/maven /usr/local/maven
rm -rf /tmp/maven.tar.gz

mkdir /root/.m2
curl -k -L -o /root/.m2/settings.xml https://raw.githubusercontent.com/liuwenru/mymacprofile/master/maven/settings.xml
curl -k -L -o /root/.m2/jvm.config https://raw.githubusercontent.com/liuwenru/mymacprofile/master/maven/jvm.config
