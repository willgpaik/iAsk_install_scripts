#!/bin/bash
# Script to install 7zip 16.02
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 4 2020
# Reference: http://www.linuxfromscratch.org/blfs/view/svn/general/p7zip.html

module load gcc

BASE=$PWD
mkdir -p $BASE/7zip_build
mkdir -p $BASE/7zip_tmp

BUILD_DIR=$BASE/7zip_build
TMPDIR=$BASE/7zip_tmp

cd $TMPDIR
wget https://sourceforge.net/projects/p7zip/files/latest/download/p7zip_16.02_src_all.bz2
tar -xf p7zip_16.02_src_all.bz2
cd p7zip_16.02
sed -i -e 's#DEST_HOME=.*#DEST_HOME="$BUILD_DIR"#g' install.sh
./install.sh
make all3
make DEST_HOME=$BUILD_DIR DEST_MAN=$BUILD_DIR/man DEST_SHARE_DOC=$BUILD_DIR/share/doc/p7zip install

cd $BASE
rm -rf $TMPDIR
