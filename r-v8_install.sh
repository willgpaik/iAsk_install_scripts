#!/bin/bash
# Script to install r-V8 with V8 3.14.5.10
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# May 12 2021

module use /gpfs/group/RISE/sw7/modules
module load r

cd ~/scratch

TMPDIR=$PWD/v8_tmp
mkdir -p TMPDIR

cd $TMPDIR
wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/v/v8-3.14.5.10-25.el7.x86_64.rpm
wget https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/v/v8-devel-3.14.5.10-25.el7.x86_64.rpm
rpm2cpio v8-3.14.5.10-25.el7.x86_64.rpm | cpio -idm
rpm2cpio v8-devel-3.14.5.10-25.el7.x86_64.rpm | cpio -idm
mv usr/ ~/v8

export PATH=$PATH:~/v8/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:~/v8/lib64
export CPATH=$CPATH:~/v8/include

R --vanilla -e 'install.packages("V8", repos="http://cran.us.r-project.org", configure.vars="INCLUDE_DIR=$HOME/v8/include LIB_DIR=$HOME/v8/lib64")'


rm -rf $TMPDIR
#> install.packages("V8", configure.vars="LIB_DIR=/gpfs/scratch/gip5038/test/v8/sr/lib64 INCLUDE_DIR=/gpfs/scratch/gip5038/test/v8/usr/include")

