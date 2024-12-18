#!/bin/bash
# Script to install armadillo 12.8.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar. 4 2024

module purge
module load cmake

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p armadillo
mkdir -p armadillo_tmp

BUILD_DIR=$PWD/armadillo
TMPDIR=$PWD/armadillo_tmp

cd $TMPDIR
# Install armadillo
wget -nc https://sourceforge.net/projects/arma/files/armadillo-12.8.1.tar.xz
tar -xf armadillo-12.8.1.tar.xz
cd armadillo-12.8.1
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR
make -j 10
make install


# Add to bashrc
if [[ -f $BUILD_DIR/lib64/libarmadillo.so ]]; then
	echo "armadillo is successfully installed!"
	module purge
	echo "# ##### armadillo >>>>>" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib64" >> ~/.bashrc
	echo "export CPATH=$CPATH:$BUILD_DIR/include" >> ~/.bashrc
	echo "# <<<<< armadillo #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "armadillo installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
