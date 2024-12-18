#!/bin/bash
# Script to install boost 1.82.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jul. 7 2023

module purge

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p boost
mkdir -p boost_tmp

BUILD_DIR=$PWD/boost
TMPDIR=$PWD/boost_tmp

cd $TMPDIR
# Install boost 1.82.0
wget -nc https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz
tar -xf boost_1_82_0.tar.gz
cd boost_1_82_0
./bootstrap.sh cxxstd=17 --prefix=$BUILD_DIR
./b2 -j $NP install


# Add to bashrc
if [[ -d $BUILD_DIR/include/boost ]]; then
	echo "boost is successfully installed!"
	module purge
	echo "# ##### boost >>>>>" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc
	echo "# <<<<< boost #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "boost installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
