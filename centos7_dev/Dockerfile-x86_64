FROM centos:centos7.9.2009 AS base

RUN curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-7.repo && curl -o /etc/yum.repos.d/epel.repo https://mirrors.aliyun.com/repo/epel-7.repo && sed -i -e '/mirrors.cloud.aliyuncs.com/d' -e '/mirrors.aliyuncs.com/d' /etc/yum.repos.d/CentOS-Base.repo && yum makecache && yum makecache fast
RUN yum -y install openssh openssh-server openssh-clients

# 安装最新版本git
RUN yum -y install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm && yum install git -y

RUN yum -y install vim gcc gcc-c++ perl-Encode* perl-Data-Dumper perl-Text-Unidecode perl-libintl autoconf automake libtool git file bison texinfo ncurses-* make gperf rsync gettext-devel wget patch CUnit-devel centos-release-scl scl-utils-build scl-utils net-tools iproute gdb 

RUN yum -y install devtoolset-8*




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
