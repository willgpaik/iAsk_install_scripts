#!/bin/bash
# Script to install dcm2niix version v1.0.20190410
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# April 20 2019

BASE=$PWD
mkdir dcm2niix
BUILD_DIR=$PWD/dcm2niix

wget https://github.com/rordenlab/dcm2niix/archive/v1.0.20190410.tar.gz
tar -xf v1.0.20190410.tar.gz
cd dcm2niix-1.0.20190410
mkdir build
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$BUILD_DIR
make && make install

cd $BASE
rm v1.0.20190410.tar.gz
rm -rf dcm2niix-1.0.20190410
