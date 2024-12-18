#!/bin/bash
# Script to install Meep 1.20.0 with libgc 8.0.4, GMP 6.1.2, zlib 1.2.11, libunistring 0.9.9,
# swig 4.0.2, mpi4py, h5py,
# Guile 3.0.2, libctl 4.5.0, MPB 1.10.0, libGDSII, h5utils 1.13.1, and Harminv 1.4.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# March 14 2019
# Updated: Oct 5 2021

BASE=$PWD
mkdir -p $BASE/MEEP_build
BUILD_DIR=$BASE/MEEP_build
mkdir -p $BASE/meeptmpdir
TMP=$BASE/meeptmpdir

module use /gpfs/group/RISE/sw7/modules
module load gcc
module load openmpi/3.1.6
module load hdf5
module load fftw
module load python
module load automake

export HDF5_LIB=/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/lib/libhdf5.so

cd $TMP

### swig 4.0.2 ###
wget -nc https://github.com/swig/swig/archive/refs/tags/v4.0.2.tar.gz
tar -xf v4.0.2.tar.gz
cd swig-4.0.2
./autogen.sh
./configure --prefix=$BUILD_DIR
make -j 2 && make install


cd $TMP

###  libgc 8.0.4  ###
wget -nc https://www.hboehm.info/gc/gc_source/gc-8.0.4.tar.gz
tar xvzf gc-8.0.4.tar.gz
cd gc-8.0.4
./configure --prefix=$BUILD_DIR
make -j 2 && make install

#cd $TMP

###  gmp 6.1.2  ###
#wget https://gmplib.org/download/gmp/gmp-6.1.2.tar.xz
#tar -xf gmp-6.1.2.tar.xz
#cd gmp-6.1.2
#./configure --prefix=$BUILD_DIR
#make && make install

#cd $TMP

###  zlib 1.2.11  ###
#wget https://zlib.net/zlib-1.2.11.tar.gz
#tar xvzf zlib-1.2.11.tar.gz
#cd zlib-1.2.11
#./configure --prefix=$BUILD_DIR
#make && make install

#cd $TMP

###  libunistring 0.9.10  ###
curl -L -o libunistring-0.9.10.tar.gz https://ftp.gnu.org/gnu/libunistring/libunistring-0.9.10.tar.gz
tar -xf libunistring-0.9.10.tar.gz
cd libunistring-0.9.10
./configure --prefix=$BUILD_DIR
make -j 2 && make install

export PATH=$BUILD_DIR/bin:$PATH
export LD_LIBRARY_PATH=$BUILD_DIR/lib:$BUILD_DIR/lib64:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH

cd $TMP

export PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig:$PKG_CONFIG_PATH

# MEEP python requires newer version of Guile: https://github.com/NanoComp/meep/issues/938
###  Guile 3.0.7  ###
curl -L -o guile-3.0.7.tar.gz https://ftp.gnu.org/gnu/guile/guile-3.0.7.tar.gz
tar -xf guile-3.0.7.tar.gz
cd guile-3.0.7
./configure --prefix=$BUILD_DIR --with-libunistring-prefix=$BUILD_DIR #CFLAGS='-I'"$BUILD_DIR"'/include' 
make -j 2 && make install

cd $TMP

### libctl 4.5.0 ###
wget -nc https://github.com/NanoComp/libctl/archive/v4.5.0.tar.gz
tar -xf v4.5.0.tar.gz
cd libctl-4.5.0/
#./configure --enable-shared --prefix=$BUILD_DIR GUILE=$BUILD_DIR/bin/guile GUILE_CONFIG=$BUILD_DIR/bin/guile-config CPPFLAGS='-I'"$BUILD_DIR"'/include'
./autogen.sh --enable-shared --prefix=$BUILD_DIR CPPFLAGS="-I$BUILD_DIR/include"
make -j 2 && make install

cd $TMP


###  MPB 1.11.1  ##
wget -nc https://github.com/NanoComp/mpb/releases/download/v1.11.1/mpb-1.11.1.tar.gz
tar -xf mpb-1.11.1.tar.gz
cd mpb-1.11.1
./configure --enable-shared --prefix=$BUILD_DIR --with-mpi --with-libctl=$BUILD_DIR/share/libctl CC=mpicc CXX=mpic++ \
LDFLAGS="-L$BUILD_DIR/lib -L/usr/local/lib -L/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/lib/" CPPFLAGS="-I$BUILD_DIR/include -I/usr/local/include -I/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/include" --with-hermitian-eps
make -j 2 && make install
# rebuild for non-MPI version
make distclean
./configure --enable-shared --prefix=$BUILD_DIR --with-libctl=$BUILD_DIR/share/libctl \
LDFLAGS="-L$BUILD_DIR/lib -L/usr/local/lib -L/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/lib/" CPPFLAGS="-I$BUILD_DIR/include -I/usr/local/include -I/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/include" --with-hermitian-eps
make -j 2 && make install

cd $TMP

### libGDSII ###
git clone https://github.com/HomerReid/libGDSII.git
cd libGDSII/
./autogen.sh --enable-shared --prefix=$BUILD_DIR
make -j 2 && make install

cd $TMP

### h5utils 1.13.1 ###
wget -nc https://github.com/NanoComp/h5utils/archive/1.13.1.tar.gz
tar -xf 1.13.1.tar.gz
cd h5utils-1.13.1
./autogen.sh --enable-shared CC=mpicc --prefix=$BUILD_DIR LDFLAGS="-L$BUILD_DIR/lib -L/usr/local/lib -L/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/lib/" CPPFLAGS="-I$BUILD_DIR/include -I/usr/local/include -I/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/include" --with-hermitian-eps
make -j 2 && make install

cd $TMP

### Harminv 1.4.1  ###
wget -nc https://github.com/NanoComp/harminv/releases/download/v1.4.1/harminv-1.4.1.tar.gz
tar -xf harminv-1.4.1.tar.gz
cd harminv-1.4.1/
./configure --enable-shared --prefix=$BUILD_DIR
make -j 2 && make install


cd $TMP

### mpi4py ###
pip3 install mpi4py --user


cd $TMP

### h5py ###
pip3 install h5py --user


cd $TMP

### MEEP 1.20.0 ###
wget -nc https://github.com/NanoComp/meep/releases/download/v1.20.0/meep-1.20.0.tar.gz
tar -xf meep-1.20.0.tar.gz
cd meep-1.20.0
./configure --prefix=$BUILD_DIR --with-mpi --with-openmp --with-libctl=$BUILD_DIR/share/libctl CC=mpicc CXX=mpic++ PYTHON=python3 \
LDFLAGS="-L$BUILD_DIR/lib -L/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/lib/" CPPFLAGS="-I$BUILD_DIR/include -I/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj/include"
make -j 2 && make install


cd $BASE
rm -rf meeptmpdir
