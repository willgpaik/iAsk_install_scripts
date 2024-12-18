#!/bin/bash
# Script to install Maker 3.01.04 with postgresql 15.2, perl 5.36.0, rmblast, and repeatmasker
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 28 2023
# Note: Requires large storage to install all requirements (~8gb) and long installation time

module purge
module load gcc
module load openmpi
module load anaconda3
module load boost
module load hdf5


if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
SCRATCH=$HOME/scratch
mkdir -p maker
mkdir -p $SCRATCH/maker_tmp

BUILD_DIR=$PWD/maker
TMPDIR=$SCRATCH/maker_tmp

# create conda environment for h5py
conda create -y -n repeatEnv h5py
source activate repeatEnv

cd $TMPDIR
wget -nc http://mirror.centos.org/centos/7/os/x86_64/Packages/perl-DBD-Pg-2.19.3-4.el7.x86_64.rpm
rpm2cpio perl-DBD-Pg-2.19.3-4.el7.x86_64.rpm | cpio -idmv
mv usr maker

cd $TMPDIR
# Install postgresql 15.2
wget -nc https://ftp.postgresql.org/pub/source/v15.2/postgresql-15.2.tar.bz2
tar -xf postgresql-15.2.tar.bz2
cd postgresql-15.2
./configure --prefix=$BUILD_DIR
make -j $NP && make install


cd $TMPDIR
# Install perl 5.36.0
wget -nc https://www.cpan.org/src/5.0/perl-5.36.0.tar.gz
tar -xf perl-5.36.0.tar.gz
cd perl-5.36.0
./configure.gnu --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin

cd $TMPDIR
# Install rmblast 2.13.0 with patch
wget -nc ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.13.0/ncbi-blast-2.13.0+-src.tar.gz
wget -nc https://www.repeatmasker.org/rmblast/isb-2.13.0+-rmblast.patch.gz
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
wget -nc https://github.com/Benson-Genomics-Lab/TRF/archive/refs/tags/v4.09.1.tar.gz
tar -xf v4.09.1.tar.gz
cd TRF-4.09.1
configure --prefix=$BUILD_DIR/TRF
make -j $NP
make install

cd $TMPDIR
# Install repeatmasker 4.1.5 with RepBase 20181026
wget -nc https://www.repeatmasker.org/RepeatMasker/RepeatMasker-4.1.5.tar.gz
tar -xf RepeatMasker-4.1.5.tar.gz -C $BUILD_DIR
wget https://www.girinst.org/server/RepBase/protected/repeatmaskerlibraries/RepBaseRepeatMaskerEdition-20181026.tar.gz
tar -xf RepBaseRepeatMaskerEdition-20181026.tar.gz -C $BUILD_DIR/RepeatMasker
cd $BUILD_DIR/RepeatMasker
perl ./configure -trf_prgm=$BUILD_DIR/TRF -rmblast_dir=$BUILD_DIR/ncbi-blast-2.13.0+-src/build

export PATH=$PATH:$BUILD_DIR/RepeatMasker

cd $TMPDIR
# Install maker 3.01.04
wget -nc https://github.com/Yandell-Lab/maker/archive/refs/tags/Version_3.01.04.tar.gz
tar -xf Version_3.01.04.tar.gz
cd maker-Version_3.01.04/src
perl Build.PL




echo "##############################"
echo "Conda environment is set to 'repeatEnv'"
echo "To load this environment:"
echo "$ module load anaconda3"
echo "$ source activate repeatEnv"
echo "You may rename it with following command:"
echo "$ conda rename -n repeatEnv <Preferred Name>"


cd $BASE

rm -rf $TMPDIR
