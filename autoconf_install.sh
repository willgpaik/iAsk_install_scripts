#!/bin/bash
# Script to install autoconfig 2.69
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 21 2019

module load gcc

BASE=$PWD
mkdir -p autoconf_build
BUILD_DIR=$BASE/autoconf_build


wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar -xf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure --prefix=$BUILD_DIR
make
make install

cd $BASE
rm autoconf-2.69.tar.gz
rm -rf autoconf-2.69

echo "export PATH=$BUILD_DIR/bin:$PATH" >> ~/.bashrc
