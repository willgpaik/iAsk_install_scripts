#!/bin/bash
# Script to install GMT with NetCDF 4.6.2
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 25 2019

# GMT and instruction links
# http://gmt.soest.hawaii.edu/projects/gmt/wiki/Installing
# http://gmt.soest.hawaii.edu/projects/gmt/wiki/BuildingGMT



USE CONDA INSTALL!!!!

module load gcc/5.3.1
module load hdf5
module load openmpi
module load blas
module load lapack
module load fftw

BASE=$PWD
mkdir -p gmt_build
BUILD_DIR=$BASE/gmt_build

# BUILD NETCDF4:
wget -nc ftp://ftp.unidata.ucar.edu/pub/netcdf/netcdf-c-4.6.2.tar.gz
tar -xf netcdf-c-4.6.2.tar.gz
cd netcdf-c-4.6.2
./configure --prefix=$BUILD_DIR
make
make install

cd $BASE

export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_DIR/lib/pkgconfig
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$CPATH:$BUILD_DIR/include
export PATH=$PATH:$BUILD_DIR/bin

# Download GMT required files
wget -nc ftp://ftp.star.nesdis.noaa.gov/pub/sod/lsa/gmt/gshhg-gmt-2.3.7.tar.gz
wget -nc ftp://ftp.star.nesdis.noaa.gov/pub/sod/lsa/gmt/dcw-gmt-1.1.4.tar.gz

tar -xf gshhg-gmt-2.3.7.tar.gz
tar -xf dcw-gmt-1.1.4.tar.gz

# Install GMT
cd $BASE
git clone https://github.com/GenericMappingTools/gmt.git
mv gmt gmt_src
cd gmt_src
mkdir build
cd build

cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR \
-DGSHHG_ROOT=$BASE/gshhg-gmt-2.3.7 \
-DDCW_ROOT=$BASE/dcw-gmt-1.1.4 \
-DNETCDF_CONFIG=$BUILD_DIR/bin/nc-config \
-DNETCDF_INCLUDE_DIR=$BUILD_DIR/include \
-DNETCDF_LIBRARY=$BUILD_DIR/lib/ -DHAVE_NETCDF4=$BUILD_DIR/
make
make install

cd $BASE
rm netcdf-c-4.6.2.tar.gz gshhg-gmt-2.3.7.tar.gz dcw-gmt-1.1.4.tar.gz
rm -rf netcdf-c-4.6.2
