#!/bin/bash

echo "Init Containers env................"

if [[ -d /opt/apps/jdk ]]; then
    ln -s /opt/apps/jdk /usr/local/jdk
fi
if [[ -d /opt/apps/ant ]]; then
    ln -s /opt/apps/ant /usr/local/ant
fi
if [[ -d /opt/apps/maven ]]; then
    ln -s /opt/apps/maven /usr/local/maven
fi
