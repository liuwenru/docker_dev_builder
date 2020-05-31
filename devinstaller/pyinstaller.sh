#!/bin/bash

if [[ $(uname -m) == "x86_64" ]]; then
  downloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/Miniconda3-py39_4.11.0-Linux-x86_64.sh"
elif [[ $(uname -m) == "aarch64" ]]; then
  if [[ -f /etc/redhat-release ]]; then
    downloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/Miniconda3-py37_23.1.0-1-Linux-aarch64.sh"
  else
    downloadurl="https://fdoc.epoint.com.cn:3366/tmp/.liuwenru/devdownload/Miniconda3-py39_4.12.0-Linux-aarch64.sh"
  fi
fi

wget --no-check-certificate -O /tmp/miniconda.sh ${downloadurl}
sh /tmp/miniconda.sh -b -p /opt/conda
ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh
echo ". /opt/conda/etc/profile.d/conda.sh" >>~/.bashrc
echo "conda activate base" >>~/.bashrc
find /opt/conda/ -follow -type f -name '*.a' -delete
find /opt/conda/ -follow -type f -name '*.js.map' -delete
/opt/conda/bin/conda clean -afy
