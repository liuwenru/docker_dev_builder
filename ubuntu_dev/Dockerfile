FROM ubuntu


COPY start.sh /start.sh
RUN chmod +x /start.sh
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8
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
















