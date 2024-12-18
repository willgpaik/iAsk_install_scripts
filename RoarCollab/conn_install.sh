#!/bin/bash
# Script to install conn 21a with MCR R2021a
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# May 22 2023

module purge

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
SCRATCH=$HOME/scratch
mkdir -p conn
mkdir -p $SCRATCH/conn_tmp

BUILD_DIR=$PWD/conn
TMPDIR=$SCRATCH/conn_tmp

cd $TMPDIR
# Install script
wget -nc https://www.nitrc.org/frs/download.php/12424/conn21a_glnxa64.zip
unzip conn21a_glnxa64.zip -d $BUILD_DIR

cd $TMPDIR
# Install MCR
mkdir mcr
wget -nc https://ssd.mathworks.com/supportfiles/downloads/R2021a/Release/5/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_R2021a_Update_5_glnxa64.zip
unzip MATLAB_Runtime_R2021a_Update_5_glnxa64.zip -d $TMPDIR/mcr
sh mcr/install -mode silent -destinationFolder $BUILD_DIR/mcr -agreeToLicense yes 


export MCRROOT=$BUILD_DIR/mcr/v910
# Add to bashrc
if [[ -f $BUILD_DIR/conn ]]; then
	echo "Conn is successfully installed!"
	module purge
	echo "# ##### Conn >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR" >> ~/.bashrc
	echo "export MCRROOT=$BUILD_DIR/mcr/v910" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/runtime/glnxa64:${MCRROOT}/bin/glnxa64:${MCRROOT}/sys/os/glnxa64:${MCRROOT}/extern/bin/glnxa64" >> ~/.bashrc
	echo "export XAPPLRESDIR=${MCRROOT}/X11/app-defaults" >> ~/.bashrc
	echo "# <<<<< Conn #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "Conn installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
