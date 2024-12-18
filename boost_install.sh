#!/bin/bash
# Script to install boost
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 26 2019
# Updated: June 20 2022
# NOTE: Submit it as a job is recommended (takes long time to build ~1 hrs)

module purge
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
# Install Boost 1.79.0
wget -nc https://boostorg.jfrog.io/artifactory/main/release/1.79.0/source/boost_1_79_0.tar.gz
tar -xf boost_1_79_0.tar.gz
cd boost_1_79_0
./bootstrap.sh cxxstd=17 --prefix=$BUILD_DIR
./b2 -j $NP install

cd $BASE

rm -rf tmpdir
