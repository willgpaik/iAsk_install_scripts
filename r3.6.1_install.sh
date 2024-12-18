#!/bin/bash
# Script to install R 3.6.1 with zlib-1.2.11, bzip2-1.0.6, xz-5.2.4, pcre-8.43
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# July 16 2019
# Updated: Sept 13 2019

module load gcc/5.3.1

sed -i '/alias r361/d' $HOME/.bashrc

BASE=$PWD
mkdir -p $BASE/R_3.6.1
BUILD_DIR=$BASE/R_3.6.1

cd $BASE

##### Install zlib 1.2.11
wget https://www.zlib.net/zlib-1.2.11.tar.gz
tar -xf zlib-1.2.11.tar.gz
cd zlib-1.2.11
./configure --prefix=$BUILD_DIR
make && make install

cd $BASE

##### Install bzip2 1.0.6
wget https://www.sourceware.org/pub/bzip2/bzip2-1.0.6.tar.gz
tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
make -f Makefile-libbz2_so
make install PREFIX=$BUILD_DIR

cd $BASE

##### Install xz 5.2.4
wget https://tukaani.org/xz/xz-5.2.4.tar.gz
tar -xf xz-5.2.4.tar.gz
cd xz-5.2.4
./configure --prefix=$BUILD_DIR
make && make install

cd $BASE

##### Install pcre 8.43
wget https://ftp.pcre.org/pub/pcre/pcre-8.43.tar.gz
tar -xf pcre-8.43.tar.gz
cd pcre-8.43
./configure --prefix=$BUILD_DIR --enable-utf
make && make install

cd $BASE

#### Install curl 7.64.1
wget https://curl.haxx.se/download/curl-7.64.1.tar.gz
tar -xf curl-7.64.1.tar.gz
cd curl-7.64.1
./configure --prefix=$BUILD_DIR
make && make install


export LD_LIBRARY_PATH=$BUILD_DIR/lib:$LD_LIBRARY_PATH
export CPATH=$BUILD_DIR/include:$CPATH
export PATH=$BUILD_DIR/bin:$PATH

cd $BASE

##### Install R 3.6.1
wget http://lib.stat.cmu.edu/R/CRAN/src/base/R-3/R-3.6.1.tar.gz
tar -xf R-3.6.1.tar.gz
cd R-3.6.1
./configure --prefix=$BUILD_DIR CPPFLAGS=-I$BUILD_DIR/include LDFLAGS=-L$BUILD_DIR/lib
make && make install

cd $BASE
rm zlib-1.2.11.tar.gz bzip2-1.0.6.tar.gz xz-5.2.4.tar.gz pcre-8.43.tar.gz R-3.6.1.tar.gz
rm -rf zlib-1.2.11 bzip2-1.0.6 xz-5.2.4 pcre-8.43 R-3.6.1

echo "alias r361='$BUILD_DIR/bin/R'" >> $HOME/.bashrc

source ~/.bashrc

if [[ -x $BUILD_DIR/bin/R ]]; then
        r361 --version
        echo R-3.6.1 is successfully installed!
        echo You can use r361 to run it!
else
        echo Could not successfully install R-3.6.1
fi

