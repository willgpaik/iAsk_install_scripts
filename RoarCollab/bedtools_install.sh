#!/bin/bash
# Script to install bedtools 2.31.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Apr 18 2024

module purge
module load r/4.3.2

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p bedtools_tmp

TMPDIR=$PWD/bedtools_tmp

cd $TMPDIR
# Install bedtools 2.31.1
wget -nc https://github.com/arq5x/bedtools2/archive/refs/tags/v2.31.1.tar.gz
tar -zxvf v2.31.1.tar.gz -C $BASE
cd $BASE/bedtools2-2.31.1
make -j $NP

BUILD_DIR=$BASE/bedtools2-2.31.1

# Add to bashrc
if [[ -f $BUILD_DIR/bin/bedtools ]]; then
	echo "bedtools is successfully installed!"
	module purge
	echo "# ##### bedtools >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "# <<<<< bedtools #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "bedtools installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
