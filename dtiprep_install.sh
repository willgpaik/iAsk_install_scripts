#!/bin/bash
# Script to install DTIPrep latest git master branch
# Installation process takes long time (~1.5 hrs)?
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Dec 2 2019
# Last updated: Jan 31 2020

module load gcc/5.3.1
module load openmpi
module load fftw
module load hdf5
module load cmake

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

BASE=$PWD
mkdir $BASE/DTITMP
mkdir -p $BASE/DTIPrep1.2.9

TMPDIR=$BASE/DTITMP
BUILDDIR=$BASE/DTIPrep1.2.9

cd $TMPDIR
git clone https://github.com/NIRALUser/DTIPrep.git
cd DTIPrep
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR
make -$NP
make install

cd $BASE

rm -rf $TMPDIR
