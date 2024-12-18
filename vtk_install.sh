#!/bin/bash
# Script to install VTK 8.2
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Apr 4 2020

module purge
module load gcc/5.3.1
module load cmake

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

if [[ ! -z "glxinfo | grep OpenGL | grep version" ]]; then
	echo "Display server found"
else
	echo "Display server not found"
fi

BASE=$PWD
mkdir -p vtk
mkdir -p vtk_tmp

BUILD_DIR=$PWD/vtk
TMPDIR=$PWD/vtk_tmp

cd $TMPDIR
# Install VTK
wget https://www.vtk.org/files/release/8.2/VTK-8.2.0.tar.gz
tar -xf VTK-8.2.0.tar.gz
cd VTK-8.2.0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DCMAKE_BUILD_TYPE=Release
make -j $NP
make install


cd $BASE

rm -rf $TMPDIR
