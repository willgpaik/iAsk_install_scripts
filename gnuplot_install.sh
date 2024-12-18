#!/bin/bash
# Script to install gnuplot 5.4.5 with libgd-2.3.3
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 9 2020

module purge
module load gcc/8.3.1

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p gnuplot
mkdir -p gnuplot_tmp

BUILD_DIR=$PWD/gnuplot
TMPDIR=$PWD/gnuplot_tmp


cd $TMPDIR
# Install libgd 2.3.3
wget -nc https://github.com/libgd/libgd/releases/download/gd-2.3.3/libgd-2.3.3.tar.gz
tar -xf libgd-2.3.3.tar.gz
cd libgd-2.3.3
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$CPATH:$BUILD_DIR/include
export PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig

cd $TMPDIR
# Install gnuplot 5.4.5
wget -nc https://sourceforge.net/projects/gnuplot/files/gnuplot/5.4.5/gnuplot-5.4.5.tar.gz
tar -xf gnuplot-5.4.5.tar.gz
cd gnuplot-5.4.5
./configure --prefix=$BUILD_DIR --with-x --with-x-dcop --with-qt --with-gpic --with-tgif --with-mif --with-regis --with-wx --with-gd=$BUILD_DIR/lib --with-lua LDFLAGS=-L$BUILD_DIR/lib CPPFLAGS=-I$BUILD_DIR/include
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR