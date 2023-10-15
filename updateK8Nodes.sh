#!/usr/bin/env bash

DEBIAN_FRONTEND=noninteractive
WORKDIR=/tmp
cd $WORKDIR

VM_USERNAME=$1
VM_PASSWORD=$2

DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade

cd /opt/scripts && git pull
cd /opt/Secure5G && git pull
cd /opt/opensource-5g-core && git pull
cd /opt/open5gs && git pull

curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
systemctl enable docker.service
swapoff -a
echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' | jq . > /etc/docker/daemon.json
systemctl daemon-reload
systemctl restart docker
systemctl restart kubelet
rm -rf /etc/cni/net.d
kubeadm reset --force --cri-socket unix:///var/run/crio/crio.sock
kubeadm reset --force --cri-socket unix:///run/containerd/containerd.sock
kubeadm reset --force --cri-socket unix:///run/cri-dockerd.sock
systemctl restart kubelet
systemctl restart containerd
systemctl enable containerd
systemctl enable kubelet
