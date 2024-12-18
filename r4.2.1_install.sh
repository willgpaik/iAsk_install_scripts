#!/bin/bash
# Script to install R 4.2.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jul 27 2022

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

module load gcc/9.3.1
moduel load openjdk

BASE=$PWD
mkdir -p $BASE/R_4.2.1
mkdir -p $BASE/R_TMPDIR
BUILD_DIR=$BASE/R_4.2.1
TMPDIR=$BASE/R_TMPDIR

export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH
export PATH=$BUILD_DIR/bin:$PATH

cd $TMPDIR

##### Install R 4.2.1
wget https://cran.r-project.org/src/base/R-4/R-4.2.1.tar.gz
tar -xf R-4.2.1.tar.gz
cd R-4.2.1
./configure --prefix=$BUILD_DIR --enable-R-shlib --enable-BLAS-shlib --with-blas --with-lapack --enable-java
make -j $NP && make install

cd $BASE
rm -rf R_TMPDIR

#echo "alias r421='$BUILD_DIR/bin/R'" >> $HOME/.bashrc

#source ~/.bashrc

#if [[ -x $BUILD_DIR/bin/R ]]; then
#        r421 --version
#        echo R-4.2.1 is successfully installed!
#        echo You can use r421 to run it!
#else
#        echo Could not successfully install R-4.2.1
#fi
