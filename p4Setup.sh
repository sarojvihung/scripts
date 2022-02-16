apt-get update && apt-get -y upgrade && apt-get update

sudo apt-get install cmake g++ git automake libtool libgc-dev bison flex \
libfl-dev libgmp-dev libboost-dev libboost-iostreams-dev \
libboost-graph-dev llvm pkg-config python3 python3-pip \
tcpdump doxygen graphviz texlive-full python-dev

pip install ipaddr scapy ply

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

git clone --recursive https://github.com/p4lang/p4c.git
cd p4c
mkdir build
cd build
cmake .. -DENABLE_MULTITHREAD=ON -DCMAKE_INSTALL_PREFIX=/mydata/p4c/
make -j4
make -j4 check
sudo make install
cd ../../

git clone https://github.com/p4lang/behavioral-model.git
cd behavioral-model
./install_deps.sh
./autogen.sh
./configure
make
sudo make install
sudo ldconfig
cd ..


python2.7 -m pip install psutil grpcio-tools rpc


git clone https://github.com/p4lang/p4runtime
sudo python2.7 setup.py install
sudo apt install curl gnupg
curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg
sudo mv bazel.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
sudo apt update && sudo apt install bazel
bazel --version

git clone https://github.com/p4lang/p4runtime
cd p4runtime
cd proto && bazel build //...
cd ../py/
sudo python2.7 setup.py install




