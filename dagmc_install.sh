#!/bin/bash
# Script to install DAGMC with MOAB
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Nov 29 2021
# Updated: Dec 15 2021

# optional
set -e

module purge
module use /gpfs/group/RISE/sw7/modules
module load gcc/8.3.1
module load openmpi/3.1.6
module load cmake/3.18.4
module load hdf5/1.10.7

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD

cd $BASE

# Install MOAB
mkdir -p MOAB/bld
cd MOAB
git clone https://bitbucket.org/fathomteam/moab
cd moab
git checkout Version5.1.0
autoreconf -fi
cd ..
ln -s moab src

cd bld
../src/configure --enable-optimize --enable-shared --disable-debug --with-hdf5 --prefix=$BASE/MOAB
make -j $NP && make install

# Install DAGMC
cd $BASE
mkdir DAGMC
cd DAGMC
git clone https://github.com/svalinn/DAGMC
cd DAGMC
git checkout develop
git submodule update --init

cd $BASE/DAGMC
ln -s DAGMC src
mkdir bld
cd bld
export INSTALL_PATH=$BASE/DAGMC
cmake ../src -DMOAB_DIR=$BASE/MOAB -DBUILD_TALLY=ON -DCMAKE_INSTALL_PREFIX=$INSTALL_PATH 
make -j $NP && make install

cd $BASE
