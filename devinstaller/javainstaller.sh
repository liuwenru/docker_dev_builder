#!/bin/bash

if [[ $(uname -m) == "x86_64" ]]; then
  jdkdownloadurl="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK8U-jdk_x64_linux_hotspot_8u312b07.tar.gz"
  jdk11downloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/OpenJDK11U-jdk_x64_linux_hotspot_11.0.8_10.tar.gz"
elif [[ $(uname -m) == "aarch64" ]]; then
  jdkdownloadurl="https://fdoc.epoint.com.cn:3366/JDK/OpenJDK/OpenJDK8U-jdk_aarch64_linux_hotspot_8u312b07.tar.gz"
  jdk11downloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/OpenJDK11U-jdk_aarch64_linux_hotspot_11.0.15_10.tar.gz"
fi

# Openjdk8 install
curl -k -o /tmp/jdk.tar.gz ${jdkdownloadurl}
mkdir /opt/openjdk8
tar -zxf /tmp/jdk.tar.gz --strip-components 1 -C /opt/openjdk8/
ln -s /opt/openjdk8 /usr/local/jdk
rm -rf /tmp/jdk.tar.gz

# Openjdk11 install
curl -k -o /tmp/jdk.tar.gz ${jdk11downloadurl}
mkdir /opt/openjdk11
tar -zxf /tmp/jdk.tar.gz --strip-components 1 -C /opt/openjdk11/
ln -s /opt/openjdk11 /usr/local/jdk11
rm -rf /tmp/jdk.tar.gz

antdownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/apache-ant-1.10.12-bin.tar.gz"
curl -k -o /tmp/ant.tar.gz ${antdownloadurl}
mkdir /opt/ant
tar -zxf /tmp/ant.tar.gz --strip-components 1 -C /opt/ant/
ln -s /opt/ant /usr/local/ant
rm -rf /tmp/ant.tar.gz

mavendownloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/apache-maven-3.8.6-bin.tar.gz"
curl -k -o /tmp/maven.tar.gz ${mavendownloadurl}
mkdir /opt/maven
tar -zxf /tmp/maven.tar.gz --strip-components 1 -C /opt/maven/
ln -s /opt/maven /usr/local/maven
rm -rf /tmp/maven.tar.gz

mkdir /root/.m2
curl -k -o /root/.m2/settings.xml https://raw.githubusercontent.com/liuwenru/mymacprofile/master/maven/settings.xml
curl -k -o /root/.m2/jvm.config https://raw.githubusercontent.com/liuwenru/mymacprofile/master/maven/jvm.config
