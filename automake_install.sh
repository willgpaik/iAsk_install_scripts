#!/bin/bash
# Script to install automake 1.16.5 with autoconf 2.71 and libtool 2.4.6
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 25 2019
# Updated: Oct 20 2021

module load gcc

BASE=$PWD
mkdir -p automake_build
mkdir -p automake_tmp
BUILD_DIR=$BASE/automake_build
TMPDIR=$BASE/automake_tmp

cd $TMPDIR
# Install autoconf 2.71
wget -nc --no-check-certificate https://ftp.gnu.org/gnu/autoconf/autoconf-2.71.tar.gz
tar -xf autoconf-2.71.tar.gz
cd autoconf-2.71
./configure --prefix=$BUILD_DIR
make
make install

cd $TMPDIR
# Install libtool 2.4.6
wget -nc --no-check-certificate  https://ftpmirror.gnu.org/libtool/libtool-2.4.6.tar.gz
tar -xf libtool-2.4.6.tar.gz
cd libtool-2.4.6
./configure --prefix=$BUILD_DIR
make && make install

export PATH=$BUILD_DIR/bin:$PATH
export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH


cd $TMPDIR
# Install gettext 0.21
wget -nc --no-check-certificate https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz
tar -xf gettext-0.21.tar.gz
cd gettext-0.21
./configure --prefix=$BUILD_DIR
make && make install


cd $TMPDIR
# Install m4
wget -nc --no-check-certificate https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.gz
tar -xf m4-1.4.19.tar.gz
cd m4-1.4.19
./configure --prefix=$BUILD_DIR
make && make install


cd $TMPDIR
# Install automake 1.16.5
wget -nc --no-check-certificate https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.gz
tar -xf automake-1.16.5.tar.gz
cd automake-1.16.5
./configure --prefix=$BUILD_DIR
make && make install


cd $BASE
rm -rf $TMPDIR
