#!/bin/bash
# Script to install GSL 2.7
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# July 19 2019
# Updated Oct 29 2021

module use /gpfs/group/RISE/sw7/modules
module load gcc/9.3.1

BASE=$PWD
mkdir -p gsl_build
BUILD_DIR=$BASE/gsl_build
mkdir gsltmp
TMPDIR=$BASE/gsltmp

cd $TMPDIR
wget https://ftp.wayne.edu/gnu/gsl/gsl-2.7.tar.gz
tar -xf gsl-2.7.tar.gz
cd gsl-2.7
./configure --prefix=$BUILD_DIR
make && make install

rm -rf $TMPDIR

# For local installation:
#echo "export PATH=$BUILD_DIR/bin:$PATH" >> ~/.bashrc
#echo "export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH" >> ~/.bashrc

# ADD Following environment variables:
# export PATH=$BUILD_DIR/bin:$PATH
# export LD_LIBRARY_PATH=$BUILD_DIR/lib:$PATH
# export CPATH=$BUILD_DIR/include/gsl:$CPATH

