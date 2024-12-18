#!/bin/bash
# Script to install ITK 4.12.2 (newer versions available but requires newer cmake)
# Recommend to use interactive job with 20 procs
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Dec 13 2019
# Last Updated: Jan 31 2020

module purge
module load gcc/5.3.1
module load cmake

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

BASE=$PWD

mkdir -p $BASE/itk-4.12
mkdir -p $BASE/itktmp

BUILDDIR=$BASE/itk-4.12
TMPDIR=$BASE/itktmp

cd $TMPDIR
wget https://github.com/InsightSoftwareConsortium/ITK/archive/v4.12.2.tar.gz
tar -xf v4.12.2.tar.gz
cd ITK-4.12.2
mkdir build
cd build
cmake .. -DBUILD_SHARED_LIBS=ON -DCMAKE_INSTALL_PREFIX=$BUILDDIR
make -j $NP
make install

if [[ -f "$BUILDDIR/bin/itkTestDriver" ]] ; then
	echo "ITK-4.12 is successfully installed"
	echo "export PATH=$PATH:$BUILDDIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILDDIR/lib" >> ~/.bashrc
else
	echo "Installation Failed"
fi

cd $BASE
rm -rf $TMPDIR
