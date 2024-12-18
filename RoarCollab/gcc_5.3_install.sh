#!/bin/bash
# Script to install gcc 5.3.0 with gmp, mpfr, mpc, and isl
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb. 12 2024
# Not working

module purge

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p gcc-5.3
mkdir -p gcc-5.3_tmp

BUILD_DIR=$PWD/gcc-5.3
TMPDIR=$PWD/gcc-5.3_tmp

cd $TMPDIR

# Install gmp 6.3.0
wget -nc https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz
tar -xf gmp-6.3.0.tar.xz
cd gmp-6.3.0
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export CPATH=$CPATH:$BUILD_DIR/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib

# Install mpfr 4.2.1
wget -nc https://www.mpfr.org/mpfr-current/mpfr-4.2.1.tar.xz
tar -xf mpfr-4.2.1.tar.xz
cd mpfr-4.2.1
./configure --prefix=$BUILD_DIR --with-gmp=$BUILD_DIR
make -j $NP && make install


# Install mpc 1.3.1
wget -nc https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz
tar -xf mpc-1.3.1.tar.gz
cd mpc-1.3.1
./configure --prefix=$BUILD_DIR --with-gmp=$BUILD_DIR
make -j $NP && make install


# Install isl 0.15
wget https://gcc.gnu.org/pub/gcc/infrastructure/isl-0.15.tar.bz2
tar -xf isl-0.15.tar.bz2
cd isl-0.15
./configure --prefix=$BUILD_DIR --with-gmp-builddir=$BUILD_DIR/lib
make -j $NP && make install

cd $TMPDIR

# Install gcc 5.3.0
wget -nc https://ftp.gnu.org/gnu/gcc/gcc-5.3.0/gcc-5.3.0.tar.gz
git clone git://gcc.gnu.org/git/gcc.git gcc-5.3.0
tar -xf gcc-5.3.0.tar.gz
cd gcc-5.3.0
./configure --with-gmp=$BUILD_DIR --with-mpfr=$BUILD_DIR --with-mpc=$BUILD_DIR --with-isl=$BUILD_DIR --prefix=$BUILD_DIR --disable-multilib CXXFLAGS="-std=gnu++98"
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR
