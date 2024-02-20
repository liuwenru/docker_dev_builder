FROM rockylinux:9.3.20231119 AS base

RUN dnf install -y dnf-plugins-core && dnf install -y epel-release && dnf config-manager --set-enabled crb

RUN yum -y install openssh openssh-server openssh-clients util-linux-user procps-ng-devel fuse-sshfs
RUN yum -y install vim gcc gcc-c++ perl-Encode* perl-Data-Dumper perl-Text-Unidecode perl-libintl autoconf automake libtool git file bison texinfo ncurses-* make gperf rsync gettext-devel wget patch CUnit-devel net-tools iproute gdb 


###############################    Devtools Env    ###############################
FROM base AS devtools
COPY devinstaller /opt/devinstaller
# Bash Plugin install
RUN bash /opt/devinstaller/toolsinstall.sh
# Lua Install
RUN bash /opt/devinstaller/luainstaller.sh

FROM devtools AS golangdev
# Golang Install
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.io,direct
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
