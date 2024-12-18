#!/bin/bash
# Script to install EMBOSS 6.6.0 and bedtools 2.28.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# July 15 2019

module load gcc/5.3.1

BASE=$PWD
mkdir -p $BASE/emboss
EBUILD=$BASE/emboss

#Install bedtools2
wget https://github.com/arq5x/bedtools2/releases/download/v2.28.0/bedtools-2.28.0.tar.gz
tar -zxvf bedtools-2.28.0.tar.gz
cd bedtools2
rm gcc g++
ln -s /opt/rh/devtoolset-4/root/usr/bin/gcc gcc
ln -s /opt/rh/devtoolset-4/root/usr/bin/g++ g++
#Following fix was found on: https://github.com/arq5x/bedtools2/issues/737
sed -i '13i #include "cram/os.h"' ./src/randomBed/randomBed.h
sed -i '17i #include "cram/os.h"' ./src/utils/BinTree/BinTree.h
sed -i '13i #include "cram/os.h"' ./src/utils/bedFile/bedFile.h
make

#Install EMBOSS
wget ftp://emboss.open-bio.org/pub/EMBOSS/EMBOSS-6.6.0.tar.gz
tar -xf EMBOSS-6.6.0.tar.gz 
cd EMBOSS-6.6.0
./configure --prefix=$EBUILD
make
make install

cd $BASE
rm -rf EMBOSS-6.6.0
rm bedtools-2.28.0.tar.gz EMBOSS-6.6.0.tar.gz

