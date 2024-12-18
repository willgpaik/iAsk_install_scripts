#!/bin/bash
# Script to install PETSc 3.12.4
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 12 2020
# IN PROGRESS

module purge
module load gcc/5.3.1
module load openmpi
module load blas
module load lapack

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p petsc
mkdir -p petsc_tmp

BUILD_DIR=$PWD/petsc
TMPDIR=$PWD/petsc_tmp

cd $TMPDIR
#Install petsc
./configure --prefix=$BUILD_DIR --with-mpi-dir=/opt/aci/sw/openmpi/1.10.1_gcc-5.3.1 --with-blas-lib=/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64/libblas.so --with-lapack-lib=/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64/liblapack.so
make -j $NP PETSC_DIR=$PWD PETSC_ARCH=arch-linux2-c-debug all
make -j $NP PETSC_DIR=$PWD PETSC_ARCH=arch-linux2-c-debug check
make install DESTDIR=$BUILD_DIR


cd $BASE

rm -rf $TMPDIR
