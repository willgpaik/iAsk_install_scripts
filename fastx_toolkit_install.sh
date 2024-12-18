#!/bin/bash
# Script to install fastx_toolkit 0.0.14 with libgtextutils 0.7
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 4 2022

module purge

BASE=$PWD
mkdir -p fastxtoolkit
mkdir -p fastxtoolkit_tmp

BUILD_DIR=$PWD/fastxtoolkit
TMPDIR=$PWD/fastxtoolkit_tmp

cd $TMPDIR
# Install libgtextutils 0.7
wget https://github.com/agordon/libgtextutils/archive/refs/tags/0.7.tar.gz
tar -xf 0.7.tar.gz
cd libgtextutils-0.7
./reconf
./configure --prefix=$BUILD_DIR
make && make install

cd $TMPDIR
# Install fastx_toolkit 0.0.14
wget https://github.com/agordon/fastx_toolkit/archive/refs/tags/0.0.14.tar.gz
tar -xf 0.0.14.tar.gz
cd fastx_toolkit-0.0.14
./reconf
./configure --prefix=$BUILD_DIR CPPFLAGS=-I$BUILD_DIR/include LDFLAGS=-L$BUILD_DIR/lib PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_DIR/lib/pkgconfig
make && make install

cd $BASE

rm -rf $TMPDIR
