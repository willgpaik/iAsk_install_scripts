#!/bin/bash
# Script to install gcc 11.2.0 with isl 0.24
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 3 2022


module purge
module load gcc

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p gcc-11.2
mkdir -p gcc-11.2_tmp

BUILD_DIR=$PWD/gcc-11.2
TMPDIR=$PWD/gcc-11.2_tmp

cd $TMPDIR

# Install isl 0.24
wget https://libisl.sourceforge.io/isl-0.24.tar.xz
tar -xf isl-0.24.tar.xz
cd isl-0.24
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export CPATH=$CPATH:$BUILD_DIR/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib

cd $TMPDIR

# Install gcc 11.2.0
wget https://mirrors.concertpass.com/gcc/releases/gcc-11.2.0/gcc-11.2.0.tar.xz
tar -xf gcc-11.2.0.tar.xz
cd gcc-11.2.0
./configure --with-isl=$BUILD_DIR --disable-multilib --prefix=$BUILD_DIR
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR
