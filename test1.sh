#!/bin/bash

cd ~
sudo apt update && sudo apt upgrade -y
sudo apt install -y git binutils-dev libcurl4-openssl-dev zlib1g-dev libdw-dev libiberty-dev cmake gcc g++ python docker protobuf-compiler libssl-dev pkg-config clang llvm cargo awscli clang build-essential make
sudo apt install python3-pip
USER_BASE_BIN=$(python3 -m site --user-base)/bin
export PATH="$USER_BASE_BIN:$PATH"

curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -  
sudo apt install build-essential nodejs
PATH="$PATH"

sudo npm install -g near-cli
export NEAR_ENV=shardnet
echo 'export NEAR_ENV=shardnet' >> ~/.bashrc
source ~/.bashrc

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

git clone https://github.com/near/nearcore
cd nearcore
git fetch
git checkout 8448ad1ebf27731a43397686103aa5277e7f2fcf
cargo build -p neard --release --features shardnet
~/nearcore/target/release/neard --version

sudo apt-get install awscli -y
~/nearcore/target/release/neard --home ~/.near init --chain-id shardnet --download-genesis
rm ~/.near/config.json ~/.near/genesis.json
wget -O ~/.near/config.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/config.json
wget -O ~/.near/genesis.json https://s3-us-west-1.amazonaws.com/build.nearprotocol.com/nearcore-deploy/shardnet/genesis.json


echo "##########################################"
echo "Environment install finished"
echo "In next step you need create near wallet"
echo "##########################################"
