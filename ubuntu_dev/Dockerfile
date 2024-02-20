FROM ubuntu AS base

# Change Ubuntu install source
RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

RUN apt-get update
RUN apt-get install -y locales gcc g++ libncurses-dev vim net-tools git curl iftop htop build-essential gdb iproute2 && \ 
  rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# SSH Install
RUN apt-get update && apt-get install -y openssh-server git
RUN mkdir /var/run/sshd
RUN echo 'root:liuwenru' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

# 配置 xvfb和x11vnc 环境
ENV DISPLAY=":1"
RUN apt-get install -y x11vnc xvfb firefox gedit-dev xdotool  
RUN mkdir /root/.vnc && \
  touch /root/.vnc/passwd && \
  x11vnc -storepasswd "p@ssw0rd" /root/.vnc/passwd

FROM base AS devtools
COPY devinstaller /opt/devinstaller
# Bash Plugin install
RUN bash /opt/devinstaller/toolsinstall.sh

# Lua Install
RUN bash /opt/devinstaller/luainstaller.sh

FROM devtools AS golangdev
# Golang Install
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn,direct
RUN bash /opt/devinstaller/golanginstaller.sh
ENV GOPATH /opt/goworkspace
ENV PATH /opt/go/bin:$GOPATH/bin:$PATH
RUN go install github.com/ramya-rao-a/go-outline@latest && \
  go install github.com/cweill/gotests/gotests@latest && \
  go install github.com/fatih/gomodifytags@latest && \
  go install github.com/josharian/impl@latest && \
  go install github.com/haya14busa/goplay/cmd/goplay@latest && \
  go install github.com/go-delve/delve/cmd/dlv@latest && \
  go install honnef.co/go/tools/cmd/staticcheck@latest && \
  go install golang.org/x/tools/gopls@latest

FROM golangdev AS nodedev  
# nvm Install
RUN bash /opt/devinstaller/nodejsinstaller.sh

FROM nodedev AS pydev
# python Install
RUN bash /opt/devinstaller/pyinstaller.sh

FROM pydev AS javadev
# 配置 Java开发环境
RUN bash /opt/devinstaller/javainstaller.sh 

ENV JAVA_HOME /usr/local/jdk
ENV PATH $JAVA_HOME/bin:$PATH

ENV ANT_HOME /usr/local/ant
ENV PATH $PATH:${ANT_HOME}/bin

ENV MAVEN_HOME /usr/local/maven
ENV PATH $PATH:${MAVEN_HOME}/bin
ENV LANG en_US.utf-8

FROM javadev AS vscodeserver
# 安装vscode server
RUN bash /opt/devinstaller/vscodeserverinstall.sh


RUN chsh -s /usr/bin/bash
COPY start.sh /start.sh
RUN chmod +x /start.sh /tini
ENTRYPOINT ["/tini", "-g", "--"]
CMD /bin/bash /start.sh

