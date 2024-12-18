#!/bin/bash
# Script to install fftw 2.1.5 with MPI
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# April 22 2019

module load gcc/5.3.1
module load openmpi

BASE=$PWD
mkdir -p fftw2_mpi
BUILD_DIR=$BASE/fftw2_mpi

wget http://www.fftw.org/fftw-2.1.5.tar.gz
tar -xf fftw-2.1.5.tar.gz
cd fftw-2.1.5
./configure --prefix=$BUILD_DIR --enable-mpi
make && make install

cd $BASE

rm fftw-2.1.5.tar.gz
rm -rf fftw-2.1.5
