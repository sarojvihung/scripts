#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
    echo 'Expected 1 CLI argument - Kubernetes join command'
    exit 1
fi

kjoincmd="$1"
echo "alias lgc='google-chrome --no-sandbox --disable-gpu'" >> ~/.bashrc
echo "export GOPATH=$HOME/go" >> ~/.bashrc
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export GO111MODULE=auto" >> ~/.bashrc
echo "export PCS_SETUP_TUN_INTF=false" >> ~/.bashrc
source ~/.bashrc
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
sh /opt/scripts/dockerInstall.sh
systemctl enable docker.service
swapoff -a
kubeadm reset --force
systemctl restart kubelet
eval $kjoincmd
