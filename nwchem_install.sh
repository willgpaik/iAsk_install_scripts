#!/bin/bash
# Script to install NWCHEM 7.0.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Modified from Chris Blanton's script
# Jan 25 2020
# Updated: Jul 22 2020
# Note: it takes long time to build

module load intel
module load mkl
module load impi

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD

wget -nc https://github.com/nwchemgit/nwchem/archive/v7.0.0-release.tar.gz
tar -xf v7.0.0-release.tar.gz
mv nwchem-7.0.0-release nwchem-7.0.0
cd nwchem-7.0.0
# NWCHEM_TOP path must be less than 64 chars
export NWCHEM_TOP=$PWD
cd src
export NWCHEM_TARGET=LINUX64
export ARMCI_NETWORK=MPI-PR
# Needed to use the correct compilers for the mpi* wrappers. 
export I_MPI_CC=icc
export I_MPI_CXX=icpc
export I_MPI_FC=ifort
export I_MPI_F77=$I_MPI_FC
export I_MPI_F90=$I_MPI_FC
# Other Options
export USE_NOFSCHECK='TRUE'
export USE_NOIO='TRUE'
export USE_MPI='Y'
export USE_MPIF='Y'
export USE_MPIF4='Y'
export MPI_LOC=/opt/intel/compilers_and_libraries_2016.3.210/linux/mpi
export MPI_INCLUDE="-I$MPI_LOC/intel64/include"
export MPI_LIB="$MPI_LOC/intel64/lib"
export LIBMPI="-lmpifort -lmpi -lmpigi -ldl -lrt -lpthread"
export NWCHEM_MODULES="all"
export LARGE_FILES='TRUE'
export HAS_BLAS='yes'
export USE_SCALAPACK='y'
export MKLLIB="$MKLROOT/lib/intel64"
export MKLINC="$MKLROOT/include"
export BLASOPT="-L$MKLLIB -lmkl_intel_ilp64 -lmkl_core -lmkl_sequential -lpthread -lm"
export LAPACK_LIB="-L$MKLLIB -lmkl_intel_ilp64 -lmkl_core -lmkl_sequential -lpthread -lm"
export SCALAPACK_LIBS="-L$MKLLIB -lmkl_scalapack_ilp64 -lmkl_intel_ilp64 -lmkl_core -lmkl_sequential -lmkl_blacs_intelmpi_ilp64 -lpthread -lm"
export SCALAPACK_SIZE=8
export BLAS_SIZE=8
export USE_64TO32=y
export FC=ifort
export CC=icc

make nwchem_config
printenv >> make.log 2>&1
make CC=icc FC=ifort FOPTIMIZE=-O3 -j $NP >> make.log 2>&1

# Remove tarball
cd $BASE
rm v7.0.0-release.tar.gz
