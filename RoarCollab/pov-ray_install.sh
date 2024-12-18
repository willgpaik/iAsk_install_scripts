#!/bin/bash
# Script to install pov-ray 3.7 with boost 1.82.0, libjpeg-turbo 3.0.0 and libtiff 4.5.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jul. 5 2023

module purge
module load boost

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p povray_tmp

BUILD_DIR=$PWD/povray
TMPDIR=$PWD/povray_tmp

cd $TMPDIR
# Install libjpeg-turbo 3.0.0
wget -nc https://sourceforge.net/projects/libjpeg-turbo/files/3.0.0/libjpeg-turbo-official-3.0.0.x86_64.rpm
rpm2cpio libjpeg-turbo-official-3.0.0.x86_64.rpm | cpio -idm

mv opt/libjpeg-turbo $BUILD_DIR


cd $TMPDIR
# Install boost 1.82.0
wget -nc https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.gz
tar -xf boost_1_82_0.tar.gz
cd boost_1_82_0
./bootstrap.sh cxxstd=17 --prefix=$BUILD_DIR
./b2 -j $NP install


cd $TMPDIR
# Install libtiff
wget -nc https://gitlab.com/libtiff/libtiff/-/archive/v4.5.1/libtiff-v4.5.1.tar.gz
tar -xf libtiff-v4.5.1.tar.gz
cd libtiff-v4.5.1
./autogen.sh
./configure --prefix=$BUILD_DIR
make -j $NP
make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$CPATH:$BUILD_DIR/include

cd $TMPDIR
# Install pov-ray
if [[ ! -d "povray" ]]; then
	git clone https://github.com/POV-Ray/povray.git
fi
cd povray
git checkout cd074e4
cd unix
./prebuild.sh
cd ..
./configure --prefix=$BUILD_DIR COMPILED_BY="'$whoami'" --with-boost=$BUILD_DIR --with-libjpeg=$BUILD_DIR/lib64/ --with-libtiff=$BUILD_DIR/lib --with-boost-libdir=$BUILD_DIR/lib
make -j $NP
make install

# Add to bashrc
if [[ -f $BUILD_DIR/bin/povray ]]; then
	echo "povray is successfully installed!"
	module purge
	echo "# ##### povray >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64" >> ~/.bashrc
	echo "# <<<<< povray #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "povray installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
