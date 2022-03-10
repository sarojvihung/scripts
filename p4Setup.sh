#Auto-method
sudo apt-get install cmake g++ git automake libtool libgc-dev bison flex \
libfl-dev libgmp-dev libboost-dev libboost-iostreams-dev mininet \
libboost-graph-dev llvm pkg-config python3 python3-pip \
tcpdump doxygen graphviz texlive-full libnanomsg-dev automake \
build-essential g++ libboost-dev libboost-system-dev libboost-thread-dev \
libtool pkg-config libpcre3-dev libavl-dev libev-dev libprotobuf-c-dev \
protobuf-c-compiler

pip3 install ipaddr scapy ply

. /etc/os-release
echo "deb http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_${VERSION_ID}/ /" | sudo tee /etc/apt/sources.list.d/home:p4lang.list
curl -L "http://download.opensuse.org/repositories/home:/p4lang/xUbuntu_${VERSION_ID}/Release.key" | sudo apt-key add -
sudo apt-get update
sudo apt install p4lang-p4c


#Docker-method
docker pull kevinbird61/new_p4env_v1
docker run -d --privileged -it 789b8b616dbb
docker ps
docker exec -it     bash
git clone https://github.com/UmakantKulkarni/p4-researching


#Manual method
DEBIAN_FRONTEND=noninteractive
cd /opt
sudo apt-get install cmake g++ git automake libtool libgc-dev bison flex \
libfl-dev libgmp-dev libboost-dev libboost-iostreams-dev mininet \
libboost-graph-dev llvm pkg-config python3 python3-pip \
tcpdump doxygen graphviz texlive-full

pip3 install ipaddr scapy ply psutil 2to3 mininet grpcio grpcio-tools
sudo apt -y install gnupg

git clone https://github.com/kevinbird61/p4-researching
mkdir p3-researching
scp -r p4-researching/* p3-researching/
2to3 -W -n p3-researching/


curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt -y update && sudo apt -y install bazel
bazel --version

cd /opt
git clone https://github.com/protocolbuffers/protobuf.git
cd protobuf
git checkout v3.18.1
git submodule update --init --recursive
./autogen.sh
./configure
make
make check
sudo make install
sudo ldconfig
cd ..


cd /opt
git clone https://github.com/p4lang/p4runtime
cd p4runtime
cd proto && bazel build //...
cd ../py/
sudo python3 setup.py install

cd /opt
git clone --depth=1 -b v1.43.2 https://github.com/google/grpc.git
cd grpc/
git submodule update --init --recursive
make
cd cmake
mkdir build
cd build
cmake ../.. -DgRPC_INSTALL=ON -DCMAKE_BUILD_TYPE=Release -DgRPC_PROTOBUF_PROVIDER=package -DgRPC_SSL_PROVIDER=package -DgRPC_ZLIB_PROVIDER=package -DBUILD_DEPS=ON
make
make install

cd /opt
git clone https://github.com/p4lang/PI
cd PI
git submodule update --init --recursive
./autogen.sh
./configure --with-proto --with-internal-rpc --with-sysrepo
make
make check
sudo make install







