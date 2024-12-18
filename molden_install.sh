#!/bin/bash
# Script to install molden 5.9
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# July 13 2020

module purge
module load gcc/5.3.1

# check host:
NAME=`hostname | grep comp-ic`
if [[ -z "$NAME" ]]; then
	echo "Please use Interactive Desktop through Portal"
	exit 1
fi


BASE=$PWD
mkdir -p molden_tmp

TMPDIR=$PWD/molden_tmp

cd $TMPDIR
wget http://mirror.centos.org/centos/6/os/x86_64/Packages/imake-1.0.2-11.el6.x86_64.rpm
rpm2cpio imake-1.0.2-11.el6.x86_64.rpm | cpio -idmv
export PATH=$PATH:$PWD/usr/bin


cd $BASE
wget ftp://ftp.cmbi.umcn.nl/pub/molgraph/molden/molden5.9.tar.gz
tar -xf molden5.9.tar.gz
cd molden5.9
make
make gmolden

echo "alias molden='$BASE/molden5.9/gmolden'" >> ~/.bashrc

cd $BASE

rm -rf $TMPDIR
