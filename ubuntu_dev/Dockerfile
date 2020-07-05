FROM ubuntu


COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN apt-get update && apt-get install -y locales vim gcc g++ && rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

RUN apt-get update && apt-get install -y openssh-server git 
RUN mkdir /var/run/sshd
RUN echo 'root:liuwenru' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

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
















