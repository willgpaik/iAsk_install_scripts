#!/bin/bash
# Script to install gnuplot 5.4.5
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Oct 14 2022

module purge

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS
else
	NP=1
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p gnuplot
mkdir -p gnuplot_tmp

BUILD_DIR=$PWD/gnuplot
TMPDIR=$PWD/gnuplot_tmp

cd $TMPDIR
# Install gnuplot 5.4.5
wget -nc https://sourceforge.net/projects/gnuplot/files/gnuplot/5.4.5/gnuplot-5.4.5.tar.gz
tar -xf gnuplot-5.4.5.tar.gz
cd gnuplot-5.4.5
./configure --prefix=$BUILD_DIR --with-x --with-x-dcop --with-qt --with-gpic --with-tgif --with-mif --with-regis
make -j $NP && make install


# Add to bashrc
if [[ -f $BUILD_DIR/bin/gnuplot ]]; then
	echo "gnuplot is successfully installed!"
	module purge
	echo "# ##### GNUPLOT >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc
	echo "# <<<<< GNUPLOT #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "gnuplot installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
