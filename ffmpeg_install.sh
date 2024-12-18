#!/bin/bash
# Script to install FFmpeg 4.2.2 with yasm 1.3.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 9 2020

module load gcc/5.3.1

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p ffmpeg
mkdir -p ffmpeg_tmp

BUILD_DIR=$PWD/ffmpeg
TMPDIR=$PWD/ffmpeg_tmp

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib

cd $TMPDIR
# Install yasm 1.3.0
wget http://www.tortall.net/projects/yasm/releases/yasm-1.3.0.tar.gz
tar -xf yasm-1.3.0.tar.gz
cd yasm-1.3.0
sed -i 's#) ytasm.*#)#' Makefile.in
./configure --prefix=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR
#Install ffmpeg 4.2.2
wget https://ffmpeg.org/releases/ffmpeg-4.2.2.tar.bz2
tar -xf ffmpeg-4.2.2.tar.bz2
cd ffmpeg-4.2.2
./configure --enable-shared --prefix=$BUILD_DIR
make -j $NP && make install

# Add to bashrc
if [[ -f $BUILD_DIR/bin/ffmpeg ]]; then
	echo "FFmpeg is successfully installed!"
	module purge
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "FFmpeg installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
