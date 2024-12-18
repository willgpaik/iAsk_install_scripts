#!/bin/bash
# Script to install R 4.0.2 with zlib-1.2.11, bzip2-1.0.6, xz-5.2.4, pcre-8.43, and libcurl 7.72.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Aug 26 2020
# Updated: Oct 11 2020

module load gcc/5.3.1

sed -i '/alias r402/d' $HOME/.bashrc

BASE=$PWD
mkdir -p $BASE/R_4.0.2
mkdir -p $BASE/R_TMPDIR
BUILD_DIR=$BASE/R_4.0.2
TMPDIR=$BASE/R_TMPDIR

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

##### Install R 4.0.2
wget http://lib.stat.cmu.edu/R/CRAN/src/base/R-4/R-4.0.2.tar.gz
tar -xf R-4.0.2.tar.gz
cd R-4.0.2
./configure --prefix=$BUILD_DIR CPPFLAGS=-I$BUILD_DIR/include LDFLAGS=-L$BUILD_DIR/lib
make && make install

cd $BASE
rm -rf R_TMPDIR

echo "alias r402='$BUILD_DIR/bin/R'" >> $HOME/.bashrc

source ~/.bashrc

if [[ -x $BUILD_DIR/bin/R ]]; then
        r402 --version
        echo R-4.0.2 is successfully installed!
        echo You can use r402 to run it!
else
        echo Could not successfully install R-4.0.2
fi

