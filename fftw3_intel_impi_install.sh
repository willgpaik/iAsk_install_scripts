#!/bin/bash
# Script to install fftw 3.3.10
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 21 2022

# optional
set -e

module purge
module use module use /gpfs/group/RISE/sw7/modules
module load intel/19.1.2 impi mkl tbb


if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p fftw3
mkdir -p fftw3_tmp

BUILD_DIR=$PWD/fftw3
TMPDIR=$PWD/fftw3_tmp

cd $TMPDIR
# Install fftw 3.3.10
wget https://www.fftw.org/fftw-3.3.10.tar.gz
tar -xf fftw-3.3.10.tar.gz
cd fftw-3.3.10
# float build
./configure --prefix=$BUILD_DIR --enable-shared --enable-single --enable-sse2 --enable-avx --enable-mpi --enable-openmp --enable-threads
make -j $NP && make install

# long double build
./configure --prefix=$BUILD_DIR --enable-shared --enable-long-double --enable-mpi --enable-openmp --enable-threads
make -j $NP && make install

# Quadruple precision may not be supported
#./configure --prefix=$BUILD_DIR --enable-shared --enable-quad-precision --enable-openmp --enable-threads
#make -j $NP && make install

cd $BASE

rm -rf $TMPDIR
