#!/bin/bash
# Script to install GHC 9.4.2
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Sep 27 2022

module purge
module load gcc/8.3.1

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p ghc
mkdir -p ghc_tmp

BUILD_DIR=$PWD/ghc
TMPDIR=$PWD/ghc_tmp

cd $TMPDIR
wget -nc https://downloads.haskell.org/~ghc/9.4.2/ghc-9.4.2-x86_64-centos7-linux.tar.xz
tar -xf ghc-9.4.2-x86_64-centos7-linux.tar.xz
cd ghc-9.4.2-x86_64-unknown-linux
./configure --prefix=$BUILD_DIR
make install

cd $BASE

rm -rf $TMPDIR
