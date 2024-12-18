#!/bin/bash
# Script to install repeatmasker 4.1.5 with h5py, rmblast 2.13.0, and TRF 4.09.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 23 2023
# Note: Requires large storage to install all requirements (~8gb) and long installation time

module purge
module load gcc
module load boost
module load anaconda3
module load hdf5

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
SCRATCH=$HOME/scratch
mkdir -p repeatmasker
mkdir -p $SCRATCH/repeatmasker_tmp

BUILD_DIR=$PWD/repeatmasker
TMPDIR=$SCRATCH/repeatmasker_tmp

# create conda environment for h5py
conda create -y -n repeatEnv h5py
source activate repeatEnv


cd $TMPDIR
# Install rmblast 2.13.0 with patch
wget ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.13.0/ncbi-blast-2.13.0+-src.tar.gz
wget https://www.repeatmasker.org/rmblast/isb-2.13.0+-rmblast.patch.gz
tar -xf ncbi-blast-2.13.0+-src.tar.gz -C $BUILD_DIR
gunzip isb-2.13.0+-rmblast.patch.gz
cd $BUILD_DIR/ncbi-blast-2.13.0+-src
patch -p1 < $TMPDIR/isb-2.13.0+-rmblast-p1.patch
cd c++
./configure --without-debug --without-krb5 --without-openssl --prefix=$BUILD_DIR/build
make -j $NP
make install

cd $TMPDIR
# Install TRF 4.09.1
wget https://github.com/Benson-Genomics-Lab/TRF/archive/refs/tags/v4.09.1.tar.gz
tar -xf v4.09.1.tar.gz
cd TRF-4.09.1
cd build
../configure --prefix=$BUILD_DIR/TRF
make -j $NP
make install

cd $TMPDIR
# Install repeatmasker 4.1.5 with RepBase 20181026
wget https://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.1.5.tar.gz
tar -xf RepeatMasker-4.1.5.tar.gz -C $BUILD_DIR
wget https://www.girinst.org/server/RepBase/protected/repeatmaskerlibraries/RepBaseRepeatMaskerEdition-20181026.tar.gz
tar -xf RepBaseRepeatMaskerEdition-20181026.tar.gz -C $BUILD_DIR/RepeatMasker
cd $BUILD_DIR/RepeatMasker
perl ./configure -trf_prgm=$BUILD_DIR/TRF -rmblast_dir=$BUILD_DIR/ncbi-blast-2.13.0+-src/build



echo "##############################"
echo "Conda environment is set to 'repeatEnv'"
echo "To load this environment:"
echo "$ module load anaconda3"
echo "$ source activate repeatEnv"
echo "You may rename it with following command:"
echo "$ conda rename -n repeatEnv <Preferred Name>"


cd $BASE

rm -rf $TMPDIR
