# docker_dev_builder
基于docker镜像构建一个日常的开发环境，方便开发，直接使用vscode 的Remote-SSH工具进行开发.

为了更快速的构建，使用了docker的buildx套件


```bash

docker buildx create --use --name mybuilder --driver-opt network=host --buildkitd-flags '--allow-insecure-entitlement network.host'

```






