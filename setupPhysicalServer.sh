#!/usr/bin/env bash

DEBIAN_FRONTEND=noninteractive

my_dir=/tmp

cd $my_dir

apt-get -y update && apt-get -y upgrade && apt-get -y update && apt-get -y dist-upgrade

DEBIAN_FRONTEND=noninteractive apt -y install python3-pip python3-setuptools python3-wheel ninja-build build-essential flex bison git libsctp-dev libgnutls28-dev libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev libmicrohttpd-dev libcurl4-gnutls-dev meson iproute2 libnghttp2-dev vim iptables cmake gnupg libtins-dev gdb tzdata ntp ntpstat ntpdate libtalloc-dev docker.io apache2-utils default-jre default-jdk wget nano make g++ lksctp-tools net-tools tcpdump curl jq iputils-ping nghttp2-client bash-completion xauth gcc autoconf libtool pkg-config libmnl-dev libyaml-dev sshpass x11-apps feh tshark openssh-client openssh-server systemd systemd-sysv dbus dbus-user-session

pip3 install -U h2

#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
apt-get -y update
apt-get install -y ca-certificates curl
apt-get install -y apt-transport-https
curl -fsSL https://dl.k8s.io/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
apt-get -y update
apt-get install -y kubectl kubelet kubeadm

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | tee /usr/share/keyrings/helm.gpg > /dev/null
apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm
systemctl restart kubelet
systemctl enable kubelet

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
echo "export PCS_SETUP_TUN_INTF=false" >> ~/.bashrc
source ~/.bashrc

echo "Download Ubuntu Purdue ZTX QCOW Image and copy it to /tmp directory - https://purdue0-my.sharepoint.com/:u:/g/personal/ukulkarn_purdue_edu/EdOFmLrrJyhFpW58BbmqFpYBf6tpfnBcDTvvefkcYNNPUA?e=TV086M"

