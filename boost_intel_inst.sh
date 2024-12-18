#!/bin/bash
# Script to install boost
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 26 2019
# Updated: March 23 2022
# NOTE: Submit it as a job is recommended (takes long time to build ~1 hrs)

module load gcc

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

BASE=$PWD
mkdir -p $BASE/tmpdir
mkdir -p $BASE/boost_build
TMPDIR=$BASE/tmpdir
BUILD_DIR=$BASE/boost_build

cd $TMPDIR
# Install Boost 1.78.0
wget -nc https://boostorg.jfrog.io/artifactory/main/release/1.78.0/source/boost_1_78_0.tar.gz
tar -xf boost_1_78_0.tar.gz
cd boost_1_78_0
./bootstrap.sh --prefix=$BUILD_DIR
./b2 -j $NP install cxxflags="-std=c++14"

module purge
module load intel
module load impi

./b2 -j $NP address-model=64 toolset=intel stage cxxflags="-std=c++14" install

cd $BASE

rm -rf tmpdir
