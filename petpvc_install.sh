#!/bin/bash
# Script to install PETPVC latest version with ITK 4.13.3
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Oct 16 2020
# Updated Nov 6 2020

# Installation may take quite a long time

module purge
module use /gpfs/group/dml129/default/sw/modules
module load gcc/5.3.1
module load cmake

BASE=$PWD
mkdir -p petpvc
mkdir -p petpvc_tmp

BUILD_DIR=$PWD/petpvc
TMPDIR=$PWD/petpvc_tmp

cd $TMPDIR
# Install ITK 4.13.3
wget https://github.com/InsightSoftwareConsortium/ITK/releases/download/v4.13.3/InsightToolkit-4.13.3.tar.gz
tar -xf InsightToolkit-4.13.3.tar.gz
cd InsightToolkit-4.13.3
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DBUILD_SHARED_LIBS=ON -DModule_ITKReview=ON
make && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$CPATH:$BUILD_DIR/include:$BUILD_DIR/include/ITK-5.1

cd $TMPDIR
# Install PETPVC
git clone https://github.com/UCL/PETPVC.git
cd PETPVC
mkdir build && cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR
make && make install

module purge
echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc


cd $BASE

rm -rf $TMPDIR
