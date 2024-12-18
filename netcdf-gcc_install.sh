#!/bin/bash
# Script to install netcdf-c 4.8.1, netcdf-fortran 4.5.4, and netcdf-cxx 4.3.1 with zlib 1.2.12
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Nov 1 2021
# Updated May 4 2022

module purge
module use /gpfs/group/RISE/sw7/modules
module load gcc/9.3.1
module load openmpi/4.1.1-gcc-9.3.1
module load hdf5/1.12.1-gcc-9.3.1

if [[ ! -z "$PBS_NODEFILE" ]]; then
        NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
        NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p $BASE/netcdf
mkdir -p $BASE/netcdf_tmp

BUILD_DIR=$PWD/netcdf
TMPDIR=$PWD/netcdf_tmp

cd $TMPDIR
# Install zlib 1.2.12
wget -nc https://zlib.net/zlib-1.2.12.tar.gz
tar -xf zlib-1.2.12.tar.gz
cd zlib-1.2.12
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64
export CPATH=$CPATH:$BUILD_DIR/include



cd $TMPDIR
# Install netcdf-c 4.8.1
wget -nc https://downloads.unidata.ucar.edu/netcdf-c/4.8.1/netcdf-c-4.8.1.tar.gz
tar -xf netcdf-c-4.8.1.tar.gz
cd netcdf-c-4.8.1
./configure --prefix=$BUILD_DIR CPPFLAGS="-I$BUILD_DIR/include -I/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1/include" LDFLAGS="-L$BUILD_DIR/lib -L/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1/lib"
make -j $NP && make install


cd $TMPDIR
# Install netcdf-fortran 4.5.4
wget -nc https://downloads.unidata.ucar.edu/netcdf-fortran/4.5.4/netcdf-fortran-4.5.4.tar.gz
tar -xf netcdf-fortran-4.5.4.tar.gz
cd netcdf-fortran-4.5.4
./configure --prefix=$BUILD_DIR CPPFLAGS="-I$BUILD_DIR/include -I/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1/include" LDFLAGS="-L$BUILD_DIR/lib -L/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1/lib"
make -j $NP && make install


cd $TMPDIR
# Install netcdf-cxx 4.3.1
wget -nc https://downloads.unidata.ucar.edu/netcdf-cxx/4.3.1/netcdf-cxx4-4.3.1.tar.gz
tar -xf netcdf-cxx4-4.3.1.tar.gz
cd netcdf-cxx4-4.3.1
./configure --prefix=$BUILD_DIR CPPFLAGS="-I$BUILD_DIR/include -I/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1/include" LDFLAGS="-L$BUILD_DIR/lib -L/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1/lib"
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR

