#!/bin/bash

# Script to install Sphire 1.3 with crYOLO and cisTEM
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jan 17 2020

module load python/3.6.3-anaconda5.0.1

BASE=$PWD

mkdir -p $PWD/sphire
mkdir -p $PWD/sphiretmp

BUILD_DIR=$PWD/sphire
TMPDIR=$PWD/sphiretmp


# INSTALL cisTEM
cd $TMPDIR
wget -O cistem-1.0.0-beta-intel-linux.tar.gz https://cistem.org/system/tdf/upload3/cistem-1.0.0-beta-intel-linux.tar.gz?file=1&type=cistem_details&id=37&force=0
tar -xf cistem-1.0.0-beta-intel-linux.tar.gz -C $BUILD_DIR

export PATH=$PATH:$BUILD_DIR/cistem-1.0.0-beta

# Following steps from http://sphire.mpg.de/wiki/doku.php?id=downloads:cryolo_1#installation
conda create -n cryolo -c anaconda python=3.6 pyqt=5 cudnn=7.1.2 numpy==1.14.5 cython wxPython==4.0.4 intel-openmp==2019.4
source activate cryolo
# Install crYOLO for CPU for now
pip install 'cryolo[cpu]' 


# INSTALL Sphire 1.3
cd $TMPDIR
wget https://cryoem.bcm.edu/cryoem/static/software/release-2.31/eman2.31_sphire1.3.linux64.sh

# LAST section should be done manually


