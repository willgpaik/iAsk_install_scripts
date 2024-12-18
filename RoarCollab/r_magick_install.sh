#!/bin/bash
# Script to install imagemagick-6
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 27 2024

# optional
set -e

module purge
module load r/4.2.1

BASE=$PWD
mkdir -p imagemagick_tmp

BUILD_DIR=~/work/imagemagick-6
TMPDIR=$PWD/imagemagick_tmp

cd $TMPDIR
# Install imagemagick 6:
wget -nc https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/i/ImageMagick-6.9.12.93-1.el8.x86_64.rpm
rpm2cpio ImageMagick-6.9.12.93-1.el8.x86_64.rpm | cpio -idm
wget -nc https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/i/ImageMagick-devel-6.9.12.93-1.el8.x86_64.rpm
rpm2cpio ImageMagick-devel-6.9.12.93-1.el8.x86_64.rpm | cpio -idm
wget -nc https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/i/ImageMagick-libs-6.9.12.93-1.el8.x86_64.rpm
rpm2cpio ImageMagick-libs-6.9.12.93-1.el8.x86_64.rpm | cpio -idm
wget -nc https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/i/ImageMagick-c++-6.9.12.93-1.el8.x86_64.rpm
rpm2cpio ImageMagick-c++-6.9.12.93-1.el8.x86_64.rpm | cpio -idm
wget -nc https://dl.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/i/ImageMagick-c++-devel-6.9.12.93-1.el8.x86_64.rpm
rpm2cpio ImageMagick-c++-devel-6.9.12.93-1.el8.x86_64.rpm | cpio -idm

mv usr ~/work/imagemagick-6

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib64

R --vanilla << EOF
install.packages('magick', repos="http://cran.us.r-project.org", configure.vars="INCLUDE_DIR=$BUILD_DIR/include/ImageMagick-6 LIB_DIR=$BUILD_DIR/lib64", lib="~/R/x86_64-pc-linux-gnu-library/4.2")
EOF

# Add to bashrc
if [[ -f $BUILD_DIR/bin/Magick-config ]]; then
	echo "PKG is successfully installed!"
	module purge
	echo "# ##### imagemagick >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib64" >> ~/.bashrc
	echo "# <<<<< imagemagick #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "imagemagick installation failed!"
fi


rm -rf $TMPDIR
