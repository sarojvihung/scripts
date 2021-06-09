cd /opt/

apt -y update

apt -y upgrade

apt -y install docker.io golang-go curl apache2-utils default-jre default-jdk wget git vim nano make g++ libsctp-dev lksctp-tools net-tools iproute2 libssl-dev tcpdump curl jq chromium-browser iputils-ping apt-transport-https nghttp2-client bash-completion

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt -y update
apt-get install -y kubelet kubeadm kubectl

systemctl enable docker.service
swapoff -a

wget https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3.tar.gz && tar -xvzf cmake-3.20.3.tar.gz

cd cmake-3.20.3 && ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && make && make install

cd .. && rm -rf cmake-*

cmake --version

git clone -b v3.2.0 https://github.com/aligungr/UERANSIM && cd UERANSIM && make

cp build/nr-* /usr/local/bin/
cd ..

curl https://baltocdn.com/helm/signing.asc | apt-key add -
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt -y update
apt-get install helm

cd /opt/
mkdir k8s
cd k8s
curl -sL https://run.linkerd.io/install | sh
curl https://docs.projectcalico.org/manifests/calico.yaml -O
wget https://raw.githubusercontent.com/pythianarora/total-practice/master/sample-kubernetes-code/metrics-server.yaml

cd /opt/
git clone https://github.com/UmakantKulkarni/opensource-5g-core
git clone https://github.com/UmakantKulkarni/free5gmano
git clone https://github.com/UmakantKulkarni/scripts
git clone https://github.com/UmakantKulkarni/open5gs
git clone https://github.com/free5gc/free5gc