#!/bin/bash
# Script to install netcdf 4.8.0 with zlib 1.2.11 and hdf5 1.12.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Apr 14 2021

module purge
module load intel

if [[ ! -z "$PBS_NODEFILE" ]]; then
        NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
        NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p netcdf
mkdir -p netcdf_tmp

BUILD_DIR=$PWD/netcdf
TMPDIR=$PWD/netcdf_tmp

cd $TMPDIR
# Install zlib 1.2.11
wget -nc https://zlib.net/zlib-1.2.11.tar.gz
tar -xf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64
export CPATH=$CPATH:$BUILD_DIR/include

cd $TMPDIR
# Install hdf5 1.12.0
wget -nc -O hdf5-1.12.0.tar.gz https://www.hdfgroup.org/package/hdf5-1-12-0-tar-gz/?wpdmdl=14582&refresh=60774c4a0b81e1618431050
tar -xf hdf5-1.12.0.tar.gz
cd hdf5-1.12.0
./configure --prefix=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR
# Install netcdf 4.8.0
wget -nc https://www.unidata.ucar.edu/downloads/netcdf/ftp/netcdf-c-4.8.0.tar.gz
tar -xf netcdf-c-4.8.0.tar.gz
cd netcdf-c-4.8.0
./configure --prefix=$BUILD_DIR
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR

