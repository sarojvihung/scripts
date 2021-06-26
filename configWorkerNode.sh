#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
    echo 'Expected 1 CLI argument - Kubernetes join command'
    exit 1
fi

kjoincmd="$1"
sh /opt/scripts/dockerInstall.sh
systemctl enable docker.service
swapoff -a
kubeadm reset --force
systemctl restart kubelet
eval $kjoincmd