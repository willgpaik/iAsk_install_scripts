#!/bin/bash
# Script to install HISAT2 2.2.1 with NGS SDK 2.10.8
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Oct 10 2020


module purge
module load gcc/5.3.1


BASE=$PWD
mkdir -p hisat2_tmp

TMPDIR=$PWD/hisat2_tmp

cd $TMPDIR
wget -O hisat2.zip https://cloud.biohpc.swmed.edu/index.php/s/fE9QCsX3NH4QwBi/download
wget http://ftp-trace.ncbi.nlm.nih.gov/sra/ngs/2.10.8/ngs-sdk.2.10.8-linux.tar.gz

unzip hisat2.zip -d ..
tar -xf ngs-sdk.2.10.8-linux.tar.gz -C ..

cd $BASE/hisat2-2.2.1
make USE_SRA=1 NCBI_NGS_DIR=$BASE/ngs-sdk.2.10.8-linux NCBI_VDB_DIR=$BASE/ngs-sdk.2.10.8-linux

cd $BASE

rm -rf $TMPDIR