#!/bin/bash
# Script to install NAMD
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 29 2019

# This script installs:
#	Charm++ 6.8.2
#	FFTW
#	TCL 8.5.9
#	NAMD 2.13 MPI version
# Cannot use this shell script (Please type line by line on terminal)

module load gcc/5.3.1
module load openmpi


BASE=$PWD

cd $BASE

# Replace below line with your source file (following link will be removed):
#wget https://git.psu.edu/gip5038/ics_files/raw/master/NAMD_2.13_Source.tar.gz
tar -xf NAMD_2.13_Source.tar.gz

cd NAMD_2.13_Source

tar -xf charm-6.8.2.tar
cd charm-6.8.2
env MPICXX=mpicxx ./build charm++ mpi-linux-x86_64 --with-production
cd mpi-linux-x86_64/tests/charm++/megatest
make pgm
mpiexec -n 4 ./pgm

cd $BASE/NAMD_2.13_Source

wget http://www.ks.uiuc.edu/Research/namd/libraries/fftw-linux-x86_64.tar.gz
tar xzf fftw-linux-x86_64.tar.gz
mv linux-x86_64 fftw
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64.tar.gz
wget http://www.ks.uiuc.edu/Research/namd/libraries/tcl8.5.9-linux-x86_64-threaded.tar.gz
tar xzf tcl8.5.9-linux-x86_64.tar.gz
tar xzf tcl8.5.9-linux-x86_64-threaded.tar.gz
mv tcl8.5.9-linux-x86_64 tcl
mv tcl8.5.9-linux-x86_64-threaded tcl-threaded

./config Linux-x86_64-g++ --charm-arch mpi-linux-x86_64
cd Linux-x86_64-g++
make

