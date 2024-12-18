#!/bin/bash
# Script to install R 4.3.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jun. 2 2023


module purge
module load jdk

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p r-4.3.0
mkdir -p r_tmp

BUILD_DIR=$PWD/r-4.3.0
TMPDIR=$PWD/r_tmp

cd $TMPDIR
# Install R 4.3.0
wget -nc https://cran.r-project.org/src/base/R-4/R-4.3.0.tar.gz
tar -xf R-4.3.0.tar.gz
cd R-4.3.0
./configure --prefix=$BUILD_DIR --enable-R-shlib --enable-R-static-lib
make -j $NP && make install


# Add to bashrc
if [[ -f $BUILD_DIR/bin/R ]]; then
	echo "r-4.3.0 is successfully installed!"
	module purge
	echo "# ##### r-4.3.0 >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib64" >> ~/.bashrc
	echo "# <<<<< r-4.3.0 #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "r-4.3.0 installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
