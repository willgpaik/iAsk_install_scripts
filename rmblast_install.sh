#!/bin/bash
# This script installs RMBlast
# Script written by: Will Paik (gip5038)
# Sept 1 2019
# Updated: Mar 23 2023

# Note: 'make' gives few error but 'make install' works without any further issue

# Recommend to install through an interactive job
# qsub -A open -I -l nodes=1:ppn=20:scivybridge -l walltime=6:00:00
if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo Number of threads used for installation: $NP

module purge
module load gcc
module load boost

BASE=$PWD
mkdir -p $BASE/rmblast
mkdir -p $BASE/rmblast_tmp
BUILD_DIR=$BASE/rmblast
TMPDIR=$BASE/rmblast_tmp

cd $TMPDIR
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.13.0/ncbi-blast-2.13.0+-src.tar.gz
wget https://www.repeatmasker.org/rmblast/isb-2.13.0+-rmblast.patch.gz

tar -xf ncbi-blast-2.13.0+-src.tar.gz
gunzip isb-2.13.0+-rmblast.patch.gz

cd ncbi-blast-2.13.0+-src
patch -p1 < ../isb-2.13.0+-rmblast-p1.patch

cd c++
#./configure --with-mt --without-debug --without-krb5 --without-openssl --with-projects=scripts/projects/rmblastn/project.lst --prefix=$BUILD_DIR
./configure --without-debug --without-krb5 --without-openssl --prefix=$BUILD_DIR
make -j $NP
make install


# FOR ALL:
#cd $BASE/ncbi-blast-2.9.0+-src/c++/ReleaseMT/build && make all_r
# FOR SELECTED:
#cd $BASE/ncbi-blast-2.9.0+-src/c++/ReleaseMT/build && make all_p

cd $BASE
rm -rf rmblast_tmp


