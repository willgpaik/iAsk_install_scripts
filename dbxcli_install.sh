#!/bin/bash
# Script to install dbxcli 3.0.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 21 2019

mkdir -p $HOME/dbxcli_bin
BASE=$HOME/dbxcli_bin

cd $BASE

wget https://github.com/dropbox/dbxcli/releases/download/v3.0.0/dbxcli-linux-amd64
mv dbxcli-linux-amd64 dbxcli
chmod +x dbxcli

echo "export PATH=$PATH:$BASE" >> ~/.bashrc

