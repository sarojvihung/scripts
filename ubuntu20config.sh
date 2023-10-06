#!/usr/bin/env bash

DEBIAN_FRONTEND=noninteractive

my_dir=/opt

cd $my_dir

apt-get -y update && apt-get -y upgrade && apt-get -y update && apt-get -y dist-upgrade

DEBIAN_FRONTEND=noninteractive apt -y install docker.io curl apache2-utils default-jre default-jdk wget git vim nano make g++ libsctp-dev lksctp-tools net-tools iproute2 libssl-dev tcpdump curl jq iputils-ping nghttp2-client bash-completion xauth gcc autoconf libtool pkg-config libmnl-dev libyaml-dev sshpass python3-pip x11-apps feh tshark

pip3 install -U h2

sudo apt-get update
sudo apt-get install -y ca-certificates curl
sudo apt-get install -y apt-transport-https
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl kubelet kubeadm

#systemctl enable docker.service
#swapoff -a

cd $my_dir
cmake_ver=3.27.6
wget https://github.com/Kitware/CMake/releases/download/v$cmake_ver/cmake-$cmake_ver.tar.gz && tar -xvzf cmake-$cmake_ver.tar.gz
cd cmake-$cmake_ver && ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && make && make install
cd .. && rm -rf cmake-*
cmake --version

cd $my_dir

git clone -b ztx_01 https://github.com/UmakantKulkarni/UERANSIM && cd UERANSIM && make

cp build/nr-* /usr/local/bin/
cd ..

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm

cd $my_dir
mkdir k8s
cd k8s
curl -sL https://run.linkerd.io/install | sh

calicoVer="v3.26.2"
cd $my_dir
cd k8s
#https://docs.tigera.io/calico/3.25/getting-started/kubernetes/self-managed-onprem/onpremises
curl https://raw.githubusercontent.com/projectcalico/calico/$calicoVer/manifests/tigera-operator.yaml -O
curl https://raw.githubusercontent.com/projectcalico/calico/$calicoVer/manifests/custom-resources.yaml -O
curl https://raw.githubusercontent.com/projectcalico/calico/$calicoVer/manifests/calico.yaml -O
#https://github.com/flannel-io/flannel#deploying-flannel-manually
curl https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml -O
wget https://raw.githubusercontent.com/UmakantKulkarni/myCodes/master/k8/metrics-server.yaml

cd $my_dir
git clone -b ztx_01 https://github.com/UmakantKulkarni/Secure5G
git clone -b ztx_01 https://github.com/UmakantKulkarni/opensource-5g-core
#git clone -b ztx_01 https://github.com/UmakantKulkarni/scripts
git clone -b ztx_01 --recursive https://github.com/UmakantKulkarni/open5gs
#git clone https://github.com/UmakantKulkarni/free5gmano
#git clone https://github.com/UmakantKulkarni/free5gc
#git clone https://github.com/UmakantKulkarni/amf
#git clone https://github.com/UmakantKulkarni/upf

#cd /opt/scripts 
#chmod +x *

#cd /opt/k8s
#wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#apt -y install ./google-chrome-stable_current_amd64.deb

if (( 0 )) ; then
    cd ~/.
    apt -y remove golang-go
    rm -rf /usr/local/go
    wget https://dl.google.com/go/go1.14.4.linux-amd64.tar.gz
    tar -C /usr/local -zxvf go1.14.4.linux-amd64.tar.gz
    rm -rf go1.14.4.linux-amd64.tar.gz
    mkdir -p ~/go/{bin,pkg,src}
    echo "export GOPATH=$HOME/go" >> ~/.bashrc
    echo "export GOROOT=/usr/local/go" >> ~/.bashrc
    echo "export GO111MODULE=auto" >> ~/.bashrc
    source ~/.bashrc
    export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
    apt -y update
    go get -u github.com/sirupsen/logrus
    sysctl -w net.ipv4.ip_forward=1
    #iptables -t nat -A POSTROUTING -o eno49 -j MASQUERADE
    iptables -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST SYN -j TCPMSS --set-mss 1400
    systemctl stop ufw
fi

cd $my_dir
modprobe -r gtp5g
git clone -b v0.6.7 https://github.com/free5gc/gtp5g.git
cd gtp5g
make
make install


#Kubernetes & containerd specific config

sudo tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Enable kernel modules
sudo modprobe overlay
sudo modprobe br_netfilter

# Add some settings to sysctl
sudo tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sudo sysctl --system

# Add Docker repo
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Install containerd
sudo apt update
sudo apt install -y containerd.io

mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# restart containerd
sudo systemctl restart containerd
sudo systemctl enable containerd
