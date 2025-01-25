#!/bin/bash
# Script to install gcc 14.2.0 with gmp, mpfr, mpc, and isl
# Written by Ghanghoon "Will" Paik ()
# Jan. 21 2025

module purge

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p gcc-14.2.0
mkdir -p gcc-14.2.0_tmp

BUILD_DIR=$PWD/gcc-14.2.0
TMPDIR=$PWD/gcc-14.2.0_tmp

cd $TMPDIR

# Install gmp 6.3.0
wget -nc https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export CPATH=$CPATH:$BUILD_DIR/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib

cd $TMPDIR

# Install mpfr 4.2.1
wget -nc https://www.mpfr.org/mpfr-current/mpfr-4.2.1.tar.xz
tar -xf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1
./configure --prefix=$BUILD_DIR --with-gmp=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR

# Install mpc 1.3.1
wget -nc https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
tar -xf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=$BUILD_DIR --with-gmp=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR

# Install isl 0.24
wget -nc https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.24.tar.bz2
tar -xf isl-0.24.tar.bz2
cd isl-0.24
./configure --prefix=$BUILD_DIR --with-gmp-builddir=$BUILD_DIR/lib
make -j $NP && make install

cd $TMPDIR

# Install gcc 14.2.0
wget -nc https://ftp.gnu.org/gnu/gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
tar -xf gcc-14.2.0.tar.xz
cd gcc-14.2.0
./configure --with-gmp=$BUILD_DIR --with-mpfr=$BUILD_DIR --with-mpc=$BUILD_DIR --with-isl=$BUILD_DIR --prefix=$BUILD_DIR --disable-multilib CXXFLAGS="-std=gnu++98"
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR
