#!/bin/bash
# Script to install NAMD
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 29 2019
# Update: Jul. 18 2023

# This script installs:
#	Charm++ 7.0.0
#	TCL 8.5.9
#	NAMD 3.0b3 MPI version
# Need source file to be downloaded before running this script

module load openmpi
module load mkl
module load fftw

BASE=$PWD

cd $BASE

# Replace below line with your source file (following link will be removed):
#wget https://git.psu.edu/gip5038/ics_files/-/raw/master/NAMD_3.0b3_Source.tar.gz
tar -xf NAMD_3.0b3_Source.tar.gz

cd NAMD_3.0b3_Source
wget -nc http://charm.cs.illinois.edu/distrib/charm-7.0.0.tar.gz
tar -xf charm-7.0.0.tar.gz
cd charm-v7.0.0
env MPICXX=mpicxx ./build charm++ mpi-linux-x86_64 --with-production --enable-tracing --enable-tracing-commthread
cd mpi-linux-x86_64/tests/charm++/megatest
make

cd $BASE/NAMD_3.0b3_Source

wget -nc http://www.ks.uiuc.edu/Research/namd/libraries/fftw-linux-x86_64.tar.gz
tar xzf fftw-linux-x86_64.tar.gz
mv linux-x86_64 fftw
wget -nc http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64.tar.gz
wget -nc http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz
tar -xzf tcl8.5.9-linux-x86_64.tar.gz
tar -xzf tcl8.5.9-linux-x86_64-threaded.tar.gz
mv tcl8.5.9-linux-x86_64 tcl
mv tcl8.5.9-linux-x86_64-threaded tcl-threaded

./config Linux-x86_64-g++ --charm-arch mpi-linux-x86_64 --with-mkl
cd Linux-x86_64-g++
make -j4

