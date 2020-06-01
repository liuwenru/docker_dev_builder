#!/bin/bash




docker build --no-cache --network=host -f Dockerfile -t centos7dev .
