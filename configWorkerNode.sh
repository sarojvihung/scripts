#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo 'Expected 2 CLI arguments - Kubernetes join command & repeat flag'
    exit 1
fi

repeatFlag="$1"
kjoincmd="$2"
echo "export GOPATH=$HOME/go" >> ~/.bashrc
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export GO111MODULE=auto" >> ~/.bashrc
echo "export PCS_SETUP_TUN_INTF=false" >> ~/.bashrc
source ~/.bashrc
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
if [ $repeatFlag = "0" ] ; then
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
fi
systemctl enable docker.service
swapoff -a
echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' | jq . > /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart kubelet
rm -rf /etc/cni/net.d
kubeadm reset --force --cri-socket unix:///var/run/crio/crio.sock
kubeadm reset --force --cri-socket unix:///run/containerd/containerd.sock
kubeadm reset --force --cri-socket unix:///run/cri-dockerd.sock
systemctl restart kubelet
systemctl restart containerd
systemctl enable containerd
systemctl enable kubelet
sleep 30
eval $kjoincmd
