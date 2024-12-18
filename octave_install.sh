#!/bin/bash
# Script to install GNU Octave
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# May 2 2019
# Last updated: May 2 2019

module load gcc/5.3.1
module load blas
module load lapack
module load openjdk

BASE=$PWD
mkdir -p octave
BUILD_DIR=$BASE/octave

# Download qscintilla 2.4.1
wget http://download-ib01.fedoraproject.org/pub/epel/6/x86_64/Packages/q/qscintilla-2.4-1.el6.x86_64.rpm
wget http://download-ib01.fedoraproject.org/pub/epel/6/x86_64/Packages/q/qscintilla-devel-2.4-1.el6.x86_64.rpm
rpm2cpio qscintilla-2.4-1.el6.x86_64.rpm | cpio -idmv
rpm2cpio qscintilla-devel-2.4-1.el6.x86_64.rpm | cpio -idmv

# Download qhull 2010.1.1
wget http://downloads.naulinux.ru/pub/NauLinux/6x/x86_64/sites/School/RPMS//qhull-2010.1-1.el6.x86_64.rpm
wget http://downloads.naulinux.ru/pub/NauLinux/6x/x86_64/sites/School/RPMS//qhull-devel-2010.1-1.el6.x86_64.rpm
rpm2cpio qhull-2010.1-1.el6.x86_64.rpm | cpio -idmv
rpm2cpio qhull-devel-2010.1-1.el6.x86_64.rpm | cpio -idmv

# Download qrupdate 1.1.2-1
wget http://download-ib01.fedoraproject.org/pub/epel/6/x86_64/Packages/q/qrupdate-1.1.2-1.el6.x86_64.rpm
wget http://download-ib01.fedoraproject.org/pub/epel/6/x86_64/Packages/q/qrupdate-devel-1.1.2-1.el6.x86_64.rpm

rpm2cpio qrupdate-1.1.2-1.el6.x86_64.rpm | cpio -idmv
rpm2cpio qrupdate-devel-1.1.2-1.el6.x86_64.rpm | cpio -idmv

mv usr/* $BUILD_DIR

rm -rf ./usr
rm *.rpm

export LD_LIBRARY_PATH=$BUILD_DIR/lib64:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH
export PATH=$BUILD_DIR/bin:$PATH

cd $BASE

# Install Octave 4.2.2
wget https://mirrors.syringanetworks.net/gnu/octave/octave-4.2.2.tar.gz
tar -xf octave-4.2.2.tar.gz
cd octave-4.2.2
./configure --prefix=$BUILD_DIR LDFLAGS="-L$BUILD_DIR/lib64 -L/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64 -L/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64" CPPFLAGS="-I$BUILD_DIR/include -I/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/include -I/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/include" QT_CFLAGS=/usr/include QT_LIBS=/usr/lib64 --with-qt=5
make && make install


cd $BASE
rm octave-4.2.2.tar.gz
rm -rf octave-4.2.2
