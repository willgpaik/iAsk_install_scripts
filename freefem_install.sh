#!/bin/bash
# Script to install FreeFEM++ 4.9 with OpenBLAS 0.3.17
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 19 2019
# Updated: Sept 29 2021
# Not working anymore

# size: ~1.6 GB

module load gcc/8.3.1
module load openmpi/3.1.6
module use /gpfs/group/RISE/sw7/modules
module load automake
module load cmake/3.18.4
module load hdf5

BASE=$PWD

mkdir freefem_build
mkdir freefemtmp
BUILD_DIR=$BASE/freefem_build
TMPDIR=$BASE/freefemtmp

cd $TMPDIR

# Install OpenBLAS
wget -nc https://github.com/xianyi/OpenBLAS/archive/refs/tags/v0.3.17.tar.gz
tar -xf v0.3.17.tar.gz./configure --enable-download --enable-optim --disable-pastix --prefix=$BUILD_DIR

cd OpenBLAS-0.3.17
make -j 2
make PREFIX=$BUILD_DIR install

cd $TMPDIR

export CPATH=$BUILD_DIR/include:$CPATH
export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH

# Install FreeFEM++
wget -nc https://github.com/FreeFem/FreeFem-sources/archive/refs/tags/v4.9.tar.gz
tar -xf v4.9.tar.gz
cd FreeFem-sources-4.9
autoupdate -f
autoreconf -fvi
./configure --enable-download --enable-optim --prefix=$BUILD_DIR CXXCPP="g++ -E" --disable-ipopt

./3rdparty/getall -a

cd 3rdparty/ff-petsc
make petsc-slepc
cd -
./reconfigure

make -j 2
make install

# Delete source files
cd $BASE
rm -rf $TMPDIR
