#!/bin/bash
# Script to install LAMMPS Oct 29 2020
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# May 20 2020
# Updated: June 19 2022

# optional
set -e

module purge
module use module use /gpfs/group/RISE/sw7/modules
module load cmake/3.18.4
module load intel/19.1.2 impi mkl tbb

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p lammps
mkdir -p lammps_tmp

BUILD_DIR=$PWD/lammps
TMPDIR=$PWD/lammps_tmp


cd $TMPDIR
### Install LAMMPS latest version ###
#wget -nc https://lammps.sandia.gov/tars/lammps-stable.tar.gz
wget -nc https://github.com/lammps/lammps/archive/refs/tags/stable_29Sep2021_update3.tar.gz -O lammps-stable.tar.gz
mkdir tmp
tar -xf lammps-stable.tar.gz -C ./tmp --strip-components=1
mv tmp lammps-stable
cd lammps-stable
sed -i "s/USR-*//g" cmake/presets/most.cmake
mkdir build
cd build

### INSTALL FFTW ###
cd $MKLROOT/interfaces/fftw2xc
make -j $NP libintel64 COMPILER=icpc PRECISION=MKL_DOUBLE INSTALL_DIR=$TMPDIR/lammps-stable/src

cd $TMPDIR/lammps-stable/build
cmake -C ../cmake/presets/most.cmake -C ../cmake/presets/intel.cmake \
	-DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DBUILD_SHARED_LIBS=ON \
	-DCMAKE_CXX_COMPILER=icpc -DPKG_KSPACE=ON -DPKG_POEMS=ON -DFFT=MKL \
	-DMKL_INCLUDE_DIRS=$MKLROOT/include -DFFT_MKL_THREADS=ON \
	-DMKL_LIBRARIES=$MKLROOT/include/lib/intel64 -DPKG_USER-REAXC=ON \
	-DPKG_USER-MEAMC=ON -DPKG_USER-INTEL=ON -DBUILD_OMP=ON \
	-DBUILD_MPI=ON -DBUILD_TOOLS=ON -DCMAKE_CXX_FLAGS=-std=c++11 \
	-DPKG_GPU=NO -DPKG_LATTE=NO -DPKG_KOKKOS=NO -DPKG_MSCG=NO \
	-DPKG_PYTHON=NO -DPKG_KIM=NO -DPKG_VORONOI=NO -DPKG_MESSAGE=NO \
	cmake ../cmake
cmake --build . -j $NP
make install



cd $BASE

rm -rf $TMPDIR
