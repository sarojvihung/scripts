#!/usr/bin/env bash

echo "alias lgc='google-chrome --no-sandbox --disable-gpu'" >> ~/.bashrc
echo "export GOPATH=$HOME/go" >> ~/.bashrc
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export GO111MODULE=auto" >> ~/.bashrc
echo "PCS_SETUP_TUN_INTF=false" >> ~/.bashrc
source ~/.bashrc
export PATH=$PATH:$GOPATH/bin:$GOROOT/bin
