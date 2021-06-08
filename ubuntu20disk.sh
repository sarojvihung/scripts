cd /opt/

apt -y update

apt -y upgrade

apt -y install docker.io curl apache2-utils default-jre default-jdk wget git vim nano make g++ libsctp-dev lksctp-tools net-tools iproute2 libssl-dev tcpdump curl jq chromium-browser iputils-ping apt-transport-https

curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
apt -y update
apt-get install -y kubelet kubeadm kubectl

systemctl daemon-reload 
systemctl restart docker
systemctl enable docker.service
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
swapoff -a

wget https://github.com/Kitware/CMake/releases/download/v3.20.3/cmake-3.20.3.tar.gz && tar -xvzf cmake-3.20.3.tar.gz

cd cmake-3.20.3 && ./bootstrap -- -DCMAKE_BUILD_TYPE:STRING=Release && make && make install

cd .. && rm -rf cmake-*

cmake --version

git clone -b v3.2.0 https://github.com/aligungr/UERANSIM && cd UERANSIM && make

cp build/nr-* /usr/local/bin/

apt -y update