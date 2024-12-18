#!/bin/bash
# Script to install geany 1.38 with gtk 3.24.37
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Apr. 13 2023


module purge
module load python
module load cmake

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p geany_tmp

BUILD_DIR=$PWD/geany
TMPDIR=$PWD/geany_tmp

cd $TMPDIR
# Install geany
wget -nc https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/g/geany-1.38-1.el8.x86_64.rpm
wget -nc https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/g/geany-devel-1.38-1.el8.x86_64.rpm
wget -nc https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/g/geany-libgeany-1.38-1.el8.x86_64.rpm
rpm2cpio geany-*.rpm | cpio -idm
mv usr geany

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$LD_LIBRARY_PATH/lib64
export CPATH=$CPATH:$BUILD_DIR/include


cd $BASE

rm -rf $TMPDIR