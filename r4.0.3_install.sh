#!/bin/bash
# Script to install R 4.0.3
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Dec 15 2020
# Updated Jan 11 2021

module load gcc

#sed -i '/alias r403/d' $HOME/.bashrc

BASE=$PWD
mkdir -p $BASE/R_4.0.3
mkdir -p $BASE/R_TMPDIR
BUILD_DIR=$BASE/R_4.0.3
TMPDIR=$BASE/R_TMPDIR

cd $TMPDIR


export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH
export PATH=$BUILD_DIR/bin:$PATH

cd $TMPDIR

##### Install R 4.0.3
wget http://lib.stat.cmu.edu/R/CRAN/src/base/R-4/R-4.0.3.tar.gz
tar -xf R-4.0.3.tar.gz
cd R-4.0.3
./configure --prefix=$BUILD_DIR --enable-R-shlib --enable-BLAS-shlib --with-blas --with-lapack
make && make install

cd $BASE
rm -rf R_TMPDIR

echo "alias r403='$BUILD_DIR/bin/R'" >> $HOME/.bashrc

source ~/.bashrc

if [[ -x $BUILD_DIR/bin/R ]]; then
        r403 --version
        echo R-4.0.3 is successfully installed!
        echo You can use r402 to run it!
else
        echo Could not successfully install R-4.0.3
fi
