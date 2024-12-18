#!/bin/bash
# Script to install MOOSE 1.0.0 with PETSc 3.17.4
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 16 2020
# Updated Aug 31 2022


module purge
module use /gpfs/group/RISE/sw7/modules
module load gcc/9.3.1
module load openmpi/4.1.4-gcc.9.3.1
module load boost/1.77.0
module load cmake/3.21.4


if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

if [[ ! -z $(grep -F "MOOSE Env" $HOME/.bashrc) ]]; then
	echo "Moose environment lines are found"
else
	echo "# MOOSE Env:
export CC=mpicc
export CXX=mpicxx
export F90=mpif90
export F77=mpif77
export FC=mpif90" >> $HOME/.bashrc
	echo "Moose environment lines are added to bashrc"
	source $HOME/.bashrc
fi

BASE=$PWD
mkdir -p moose
mkdir -p moose_tmp

BUILD_DIR=$PWD/moose
TMPDIR=$PWD/moose_tmp

cd $TMPDIR
# Install PETSc 3.17.4
wget -nc https://ftp.mcs.anl.gov/pub/petsc/release-snapshots/petsc-3.17.4.tar.gz
tar -xf petsc-3.17.4.tar.gz
cd petsc-3.17.4
./configure --prefix=$BUILD_DIR --download-fblaslapack --download-hypre --download-metis --download-parmetis --download-superlu_dist --download-mumps --download-scalapack --with-debugging=no
make -j $NP PETSC_DIR=$PWD PETSC_ARCH=arch-linux-c-opt all
make PETSC_DIR=$PWD PETSC_ARCH=arch-linux-c-opt install

export PETSC_DIR=$BUILD_DIR
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$CPATH:$BUILD_DIR/include

cd $TMPDIR
# Install Moose 1.0.0
git clone https://github.com/idaholab/moose.git
cd moose
git checkout master
./scripts/update_and_rebuild_libmesh.sh


cd $BASE

rm -rf $TMPDIR
