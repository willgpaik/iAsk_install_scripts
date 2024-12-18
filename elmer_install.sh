#!/bin/bash
# Script to install Elmer (https://www.csc.fi/web/elmer/elmer)
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# May 5 2019
# Last updated: May 5 2019


module load gcc/5.3.1
module load blas
module load lapack

BASE=$PWD
mkdir -p elmer
BUILD_DIR=$BASE/elmer

git clone git://www.github.com/ElmerCSC/elmerfem
cd elmerfem
mkdir build
cd build

cmake .. -DWITH_ELMERGUI:BOOL=FALSE -DWITH_MPI:BOOL=FALSE -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DCMAKE_CXX_COMPILER=g++ -DCMAKE_C_COMPILER=gcc -DCMAKE_Fortran_COMPILER=gfortran

make && make install

if [[ ! -f $(which ElmerSolver) ]] ; then
	echo "export ELMER_HOME=$BUILD_DIR" >> ~/.bashrc
	echo "export PATH=$PATH:$ELMER_HOME/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ELMER_HOME/lib" >> ~/.bashrc
fi

source ~/.bashrc

if [[ -f $(which ElmerSolver) ]] ; then
	echo "Elmer is successfully installed"
fi
