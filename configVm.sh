#!/usr/bin/env bash

DEBIAN_FRONTEND=noninteractive

my_dir=/opt

cd $my_dir

DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
DEBIAN_FRONTEND=noninteractive apt-get -y update
DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade

DEBIAN_FRONTEND=noninteractive apt -y install python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libmicrohttpd-dev libcurl4-gnutls-dev meson iproute2 libnghttp2-dev vim iptables cmake gnupg libtins-dev gdb tzdata ntp ntpstat ntpdate libtalloc-dev docker.io apache2-utils default-jre default-jdk wget nano make g++ lksctp-tools net-tools tcpdump curl jq iputils-ping nghttp2-client bash-completion xauth gcc autoconf libtool pkg-config libmnl-dev libyaml-dev sshpass x11-apps feh tshark openssh-client openssh-server systemd systemd-sysv dbus dbus-user-session

echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl restart ssh
systemctl enable ssh

pip3 install -U h2

#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
apt-get -y update
apt-get install -y ca-certificates curl
apt-get install -y apt-transport-https
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get -y update
apt-get install -y kubectl kubelet kubeadm

# Install kind For AMD64 / x86_64
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
mv ./kind /usr/local/bin/kind

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

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm

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
git clone -b ztx_01 https://github.com/UmakantKulkarni/scripts
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

cd $my_dir
modprobe -r gtp5g
git clone -b v0.6.7 https://github.com/free5gc/gtp5g.git
cd gtp5g
make
make install


#Kubernetes & containerd specific config

tee /etc/modules-load.d/k8s.conf <<EOF
overlay
br_netfilter
EOF

# Enable kernel modules
modprobe overlay
modprobe br_netfilter

# Add some settings to sysctl
tee /etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Reload sysctl
sysctl --system

# Install containerd
apt update
apt install -y containerd.io

mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml >/dev/null 2>&1
sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

# restart containerd
systemctl restart containerd
systemctl enable containerd

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
echo "Waiting for 30 seconds ..."
sleep 30

#https://istio.io/latest/docs/setup/getting-started/#download
cd /opt
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.19.3 TARGET_ARCH=x86_64 sh -
cd istio-1.19.3
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
