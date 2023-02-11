#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo 'Expected 2 CLI arguments - Interface name & repeat flag'
    exit 1
fi

intf="$1"
repeatFlag="$2"
ip=$(ip addr show $intf | grep -o "inet [0-9]*\.[0-9]*\.[0-9]*\.[0-9]*" | grep -o "[0-9]*\.[0-9]*\.[0-9]*\.[0-9]*")
if [ $repeatFlag = "0" ] ; then
    curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh
fi
systemctl enable docker.service
swapoff -a
echo '{"exec-opts": ["native.cgroupdriver=systemd"]}' | jq . > /etc/docker/daemon.json
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo systemctl restart kubelet
kubeadm reset --force --cri-socket unix:///var/run/crio/crio.sock
kubeadm reset --force --cri-socket unix:///run/containerd/containerd.sock
kubeadm reset --force --cri-socket unix:///run/cri-dockerd.sock
systemctl restart kubelet
systemctl restart containerd
systemctl enable containerd
systemctl enable kubelet
sleep 30
kubeadm init --pod-network-cidr=10.244.0.0/16 --token-ttl=0 --apiserver-advertise-address=$ip
export KUBECONFIG=/etc/kubernetes/admin.conf
sleep 60
kubectl get node
#https://docs.tigera.io/calico/3.25/getting-started/kubernetes/self-managed-onprem/onpremises
cd /opt/k8s && kubectl create -f tigera-operator.yaml
cd /opt/k8s && kubectl create -f custom-resources.yaml
cd /opt/k8s && kubectl apply -f calico.yaml
cd /opt/k8s && kubectl create -f metrics-server.yaml
kubectl get pods -A
kjoincmd=$(kubeadm token create --print-join-command)

sleep 30

# mTLS Working - https://istio.io/latest/docs/ops/configuration/traffic-management/tls-configuration/
# Install Inject and uninstall istio
# https://istio.io/latest/docs/setup/getting-started/
if [ $repeatFlag = "0" ] ; then
    cd /opt
    curl -L https://istio.io/downloadIstio | sh -
    cd istio-1.16.2
    echo "export PATH=$PWD/bin:$PATH" >> ~/.bashrc
    export PATH=$PWD/bin:$PATH

    echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
    echo "alias k='kubectl'" >> ~/.bashrc
    echo "alias kp='kubectl get pods --all-namespaces'" >> ~/.bashrc
    echo "alias ks='kubectl get services --all-namespaces'" >> ~/.bashrc
    echo "alias kn='kubectl get nodes'" >> ~/.bashrc
    echo "alias kt='kubectl top pods --containers'" >> ~/.bashrc
    echo "alias wkp='watch kubectl get pods -A'" >> ~/.bashrc
    echo "alias kl='kubectl logs'" >> ~/.bashrc
    echo "alias ke='kubectl exec -it'" >> ~/.bashrc
    echo "alias kd='kubectl delete pod'" >> ~/.bashrc
    echo "alias kds='kubectl describe pod'" >> ~/.bashrc
    echo "source <(kubectl completion bash)" >> ~/.bashrc
    echo "complete -F __start_kubectl k" >> ~/.bashrc
    echo "export GOPATH=$HOME/go" >> ~/.bashrc
    echo "export GOROOT=/usr/local/go" >> ~/.bashrc
    echo "export GO111MODULE=auto" >> ~/.bashrc
    echo "export PCS_SETUP_TUN_INTF=false" >> ~/.bashrc
    source ~/.bashrc
    export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
fi