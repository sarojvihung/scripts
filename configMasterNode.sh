#!/usr/bin/env bash

if [[ $# -ne 1 ]] ; then
    echo 'Expected 1 CLI argument - Interface name'
    exit 1
fi

intf="$1"
ip=$(ip addr show $intf | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
sh /opt/scripts/dockerInstall.sh
systemctl enable docker.service
swapoff -a
kubeadm reset --force
systemctl restart kubelet
kubeadm init --pod-network-cidr=10.244.0.0/16 --token-ttl=0 --apiserver-advertise-address=$ip
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl get node
cd /opt/k8s && kubectl apply -f calico.yaml
cd /opt/k8s && kubectl create -f metrics-server.yaml
kubectl get pods -A
kjoincmd=$(kubeadm token create --print-join-command)

echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kp='kubectl get pods --all-namespaces'" >> ~/.bashrc
echo "alias ks='kubectl get services --all-namespaces'" >> ~/.bashrc
echo "alias kn='kubectl get nodes'" >> ~/.bashrc
echo "alias kt='kubectl top pods --containers'" >> ~/.bashrc
echo "alias wkp='watch kubectl get pods -A'" >> ~/.bashrc
echo "alias lgc='google-chrome --no-sandbox --disable-gpu'" >> ~/.bashrc
echo "alias kl='kubectl logs'" >> ~/.bashrc
echo "alias ke='kubectl exec -it'" >> ~/.bashrc
echo "alias kd='kubectl delete pod'" >> ~/.bashrc
echo "alias kds='kubectl describe pod'" >> ~/.bashrc
echo "source <(kubectl completion bash)" >> ~/.bashrc
source ~/.bashrc
echo "export GOPATH=$HOME/go" >> ~/.bashrc
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
source ~/.bashrc
echo "export PATH=$PATH:$GOPATH/bin:$GOROOT/bin" >> ~/.bashrc
echo "export GO111MODULE=auto" >> ~/.bashrc
source ~/.bashrc