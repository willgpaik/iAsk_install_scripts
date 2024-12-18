#!/bin/bash
# Script to install macaulay2 1.15-1 with gc 7.2d-7
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# May 25 2025

module purge

BASE=$PWD
mkdir -p macaulay2_tmp

BUILD_DIR=$PWD/macaulay2
TMPDIR=$PWD/macaulay2_tmp

cd $TMPDIR
#Install script
wget -nc http://www2.macaulay2.com/Macaulay2/Downloads/GNU-Linux/Red%20Hat%20Enterprise,%20CentOS,%20Scientific%20Linux/Macaulay2-1.15-1.x86_64-Linux-CentOS-8.1.1911.rpm
wget -nc http://mirror.centos.org/centos/7/os/x86_64/Packages/gc-7.2d-7.el7.x86_64.rpm
rpm2cpio Macaulay2-1.15-1.x86_64-Linux-CentOS-8.1.1911.rpm | cpio -idm
rpm2cpio gc-7.2d-7.el7.x86_64.rpm | cpio -idm
mv usr $BUILD_DIR


# Add to bashrc
if [[ -f $BUILD_DIR/bin/M2 ]]; then
	echo "macaulay2 is successfully installed!"
	module purge
	echo "# ##### macaulay2 >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib64" >> ~/.bashrc
	echo "# <<<<< macaulay2 #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "macaulay2 installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
