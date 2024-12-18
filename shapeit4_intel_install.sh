#!/bin/bash
# Script to install shapeit4-4.2.2 with htslib-1.14 and boost-1.78.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 10 2022
# Updated: Feb 25 2022

module purge
module load intel
module --expert load gcc

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p shapeit4_tmp

BUILD_DIR=$PWD/shapeit4-4.2.2
TMPDIR=$PWD/shapeit4_tmp

cd $TMPDIR
# Install Boost 1.78.0
wget -nc https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.tar.gz
tar -xf boost_1_78_0.tar.gz
cd boost_1_78_0
./bootstrap.sh --prefix=$BUILD_DIR
./b2 -j $NP install cxxflags="-std=c++14"
./b2 -j $NP address-model=64 toolset=intel stage cxxflags="-std=c++14" install


cd $TMPDIR
wget -nc https://github.com/odelaneau/shapeit4/archive/refs/tags/v4.2.2.tar.gz
tar -xf v4.2.2.tar.gz -C $BASE

cd $TMPDIR
# Install htslib 1.14
wget -nc https://github.com/samtools/htslib/releases/download/1.14/htslib-1.14.tar.bz2
tar -xf htslib-1.14.tar.bz2
cd htslib-1.14
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$CPATH:$BUILD_DIR/include

export HTSLIB_INC=$BUILD_DIR/include/htslib
export HTSLIB_LIB=$BUILD_DIR/lib/libhts.a

export BOOST_ROOT=$BUILD_DIR
export BOOST_INC=$BOOST_ROOT/include
export BOOST_LIB_IO=$BOOST_ROOT/lib/libboost_iostreams.a
export BOOST_LIB_PO=$BOOST_ROOT/lib/libboost_program_options.a


cd $BUILD_DIR
# Install shapeit4 4.2.2
sed -i '4,11d' makefile
sed -i 's/g++/icpc/g' makefile
make -j $NP


cd $BASE

rm -rf $TMPDIR