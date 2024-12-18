#!/bin/bash
# Script to install Meep with libgc 8.0.2, GMP 6.1.2, zlib 1.2.11, libunistring 0.9.9,
# Guile 2.2.4, libctl 4.3.0, MPB 1.8.0, and Harminv 1.4.1
# Note: Don't put "export CPATH=$CPATH:$BUILD_DIR/include" before building Guile
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# March 14 2019
# Updated June 19 2019
# NOTE: Need to build twice in some reason. Don't delete meeptmpdir for first build

module load gcc/5.3.1
module load blas/3.6.0
module load lapack/3.6.0
module load hdf5
module load python

BASE=$PWD
mkdir -p $BASE/MEEP_build
BUILD_DIR=$BASE/MEEP_build
mkdir -p $BASE/meeptmpdir
TMP=$BASE/meeptmpdir

cd $TMP

###  libgc 8.0.2  ###
wget -nc https://www.hboehm.info/gc/gc_source/gc-8.0.2.tar.gz
tar xvzf gc-8.0.2.tar.gz
cd gc-8.0.2
./configure --prefix=$BUILD_DIR
make && make install

cd $TMP

###  gmp 6.1.2  ###
wget -nc https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz
tar -xf gmp-6.1.2.tar.xz
cd gmp-6.1.2
./configure --prefix=$BUILD_DIR
make && make install

cd $TMP

###  zlib 1.2.11  ###
wget -nc https://zlib.net/zlib-1.2.11.tar.gz
tar xvzf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=$BUILD_DIR
make && make install

cd $TMP

###  libunistring 0.9.9  ###
wget -nc http://ftp.gnu.org/gnu/libunistring/libunistring-0.9.9.tar.xz
tar -xf libunistring-0.9.9.tar.xz
cd libunistring-0.9.9
./configure --prefix=$BUILD_DIR
make && make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib

cd $TMP

export PKG_CONFIG_PATH=/usr/lib64/pkgconfig:$BUILD_DIR/lib/pkgconfig

###  Guile 2.2.4  ###
wget -nc http://gnu.mirrors.pair.com/guile/guile-2.2.4.tar.gz
tar xvzf guile-2.2.4.tar.gz
cd guile-2.2.4
./configure --prefix=$BUILD_DIR CFLAGS='-I'"$BUILD_DIR"'/include' 
make && make install

cd $TMP

### libctl 4.3.0 ###
#wget -nc https://github.com/NanoComp/libctl/releases/download/v4.2.0/libctl-4.2.0.tar.gz
#tar xvzf libctl-4.2.0.tar.gz
#cd libctl-4.2.0/
wget -nc https://github.com/NanoComp/libctl/releases/download/v4.3.0/libctl-4.3.0.tar.gz
tar -xf libctl-4.3.0.tar.gz
cd libctl-4.3.0
./configure --enable-shared --prefix=$BUILD_DIR GUILE=$BUILD_DIR/bin/guile GUILE_CONFIG=$BUILD_DIR/bin/guile-config CPPFLAGS='-I'"$BUILD_DIR"'/include'
make && make install

cd $TMP

export BLAS_LIBS=/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64/libblas.so
export LAPACK_LIBS=/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64/liblapack.so
export PATH=$BUILD_DIR/bin:$PATH
export CPATH=$CPATH:$BUILD_DIR/include


###  MPB 1.8.0  ##
wget -nc https://github.com/NanoComp/mpb/releases/download/v1.8.0/mpb-1.8.0.tar.gz
tar xvzf mpb-1.8.0.tar.gz
cd mpb-1.8.0
./configure --enable-shared --prefix=$BUILD_DIR --with-libctl=$BUILD_DIR/share/libctl --with-blas=/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64/libblas.so --with-lapack=/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64/liblapack.so
make && make install

cd $TMP

#set environment variable BLAS_LIBS and LAPACK_LIBS.
export BLAS_LIBS=/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64/libblas.so
export LAPACK_LIBS=/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64/liblapack.so


### Harminv 1.4.1  ###
wget -nc https://github.com/NanoComp/harminv/releases/download/v1.4.1/harminv-1.4.1.tar.gz
tar xvzf harminv-1.4.1.tar.gz
cd harminv-1.4.1/
./configure --enable-shared --prefix=$BUILD_DIR --with-blas=/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64/libblas.so --with-lapack=/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64/liblapack.so
make && make install

cd $TMP

export HDF5_LIB=/opt/aci/sw/hdf5/1.8.18_gcc-5.3.1/lib64/libhdf5.so

### MEEP 1.9.0 ###
wget -nc https://github.com/NanoComp/meep/releases/download/v1.9.0/meep-1.9.0.tar.gz
tar xvzf meep-1.9.0.tar.gz
cd meep-1.9.0
./configure --prefix=$BUILD_DIR --with-libctl=$BUILD_DIR/share/libctl --enable-shared PYTHON=python3
make && make install


cd $BASE
rm -rf meeptmpdir
