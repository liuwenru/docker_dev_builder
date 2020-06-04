FROM registry.epoint.com.cn/base/centos:7.8.2003


COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN yum -y install  epel-release
RUN yum -y install openssh openssh-server openssh-clients net-tools iproute gdb
RUN yum -y install vim gcc gcc-c++ perl-Encode*  perl-Data-Dumper perl-Text-Unidecode   perl-libintl autoconf automake git file bison texinfo ncurses-* make gperf rsync gettext-devel wget patch CUnit-devel
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini


ENV JAVA_HOME /usr/local/jdk
ENV PATH $JAVA_HOME/bin:$PATH

ENV ANT_HOME /usr/local/ant
ENV PATH $PATH:${ANT_HOME}/bin


ENV MAVEN_HOME /usr/local/maven
ENV PATH $PATH:${MAVEN_HOME}/bin
ENV LANG en_US.utf-8

RUN chmod +x /start.sh /tini
ENTRYPOINT ["/tini", "-g", "--"]
CMD /start.sh
















