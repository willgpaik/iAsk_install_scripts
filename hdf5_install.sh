#!/bin/bash
# Script to install hdf5 1.12
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Apr 6 2022


module purge
module load gcc/9.3.1
module use /gpfs/group/RISE/sw7/modules
module load cmake/3.18.4


if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p hdf5
mkdir -p hdf5_tmp

BUILD_DIR=$PWD/hdf5
TMPDIR=$PWD/hdf5_tmp

cd $TMPDIR
# Install hdf5 1.12.1
wget -nc https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.12/hdf5-1.12.1/src/CMake-hdf5-1.12.1.tar.gz
tar -xf CMake-hdf5-1.12.1.tar.gz
cd CMake-hdf5-1.12.1
./build-unix.sh
./HDF5-1.12.1-Linux.sh --skip-license --prefix=$BUILD_DIR
cd build
make -j $NP
make install

cd $BASE

rm -rf $TMPDIR
