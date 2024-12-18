#!/bin/bash
# Script to install R 4.0.3 with Intel MKL, zlib 1.2.11, bzip 1.0.6,
# xz 5.2.4, pcre 8.43, and curl 7.72.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Nov 2 2020

# optional

module purge
module load gcc

BASE=$PWD
mkdir -p R-4.0.3
mkdir -p R_tmp

BUILD_DIR=$PWD/R-4.0.3
TMPDIR=$PWD/R_tmp

cd $TMPDIR

##### Install zlib 1.2.11
wget https://www.zlib.net/zlib-1.2.11.tar.gz
tar -xf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=$BUILD_DIR
make && make install

cd $TMPDIR

##### Install bzip2 1.0.6
wget https://www.sourceware.org/pub/bzip2/bzip2-1.0.6.tar.gz
tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
make -f Makefile-libbz2_so
make install PREFIX=$BUILD_DIR

cd $TMPDIR

##### Install xz 5.2.4
wget https://tukaani.org/xz/xz-5.2.4.tar.gz
tar -xf xz-5.2.4.tar.gz
cd xz-5.2.4
./configure --prefix=$BUILD_DIR
make && make install

cd $TMPDIR

##### Install pcre 8.43
wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
tar -xf pcre-8.43.tar.gz
cd pcre-8.43
./configure --prefix=$BUILD_DIR --enable-utf
make && make install

cd $TMPDIR

#### Install curl 7.72.0
wget https://curl.haxx.se/download/curl-7.72.0.tar.gz
tar -xf curl-7.72.0.tar.gz
cd curl-7.72.0
./configure --prefix=$BUILD_DIR
make && make install


export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH
export PATH=$BUILD_DIR/bin:$PATH

cd $TMPDIR

#### Install R 4.0.3
module purge
module load intel
module load mkl/2019.5

export CC="icc -std=c99"
export CFLAGS="-g -O3 -ip -mp -wd188"
export FC=ifort
export FLAGS="-g -O3 -mp"
export CXX="icpc -std=c++14"
export CXXFLAGS="-g -O3 -mp"
export SHLIB_CXXLD=icpc
export LD_FLAGS="-L/opt/intel/compilers_and_libraries_2019.5.281/linux/mkl/lib/intel64_lin -L/usr/local/lib64 -L$BUILD_DIR/lib"
export SHLIB_LDFLAGS="-L/opt/intel/compilers_and_libraries_2019.5.281/linux/mkl/lib/intel64_lin -L/usr/local/lib64"
export CPPFLAGS="-no-gcc -I$BUILD_DIR/include"


wget https://cran.r-project.org/src/base/R-4/R-4.0.3.tar.gz
tar -xf R-4.0.3.tar.gz
cd R-4.0.3
./configure --with-blas="-L/opt/intel/compilers_and_libraries_2016.3.210/linux/mkl/lib/intel64 -lmkl_intel_ilp64 -lmkl_core -lmkl_intel_thread -lpthread -liomp5 -lm -ldl" --with-lapack --prefix=$BUILD_DIR
make && make install


cd $BASE

rm -rf $TMPDIR
