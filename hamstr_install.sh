#!/bin/bash
# Script to install hamstr
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Sept 14 2018
# Last updated: Oct 12 2018

main=$(pwd)

module load gcc/5.3.1
module load ncbi-blast

#wget -N https://sourceforge.net/projects/hamstr/files/latest/download/hamstr.v13.2.6-bin-lib.tar.gz
wget -N https://sourceforge.net/projects/hamstr/files/hamstr.v13.2.6.tar.gz

if [[ ! -d "hamstr_build" ]] ; then
    tar -xf hamstr.v13.2.6.tar.gz
    mv ./hamstr.v13.2.6 ./hamstr_build
fi

mkdir -p downloads
mkdir -p build

cd downloads
wget -N https://mafft.cbrc.jp/alignment/software/mafft-7.407-gcc_fc6.x86_64.rpm
wget -N http://www.clustal.org/download/current/clustalw-2.1.tar.gz
wget -N http://eddylab.org/software/hmmer/hmmer.tar.gz
wget -N https://www.ebi.ac.uk/~birney/wise2/wise2.4.1.tar.gz
#wget -N https://www.cpan.org/src/5.0/perl-5.28.0.tar.gz
#wget -N https://rpmfind.net/linux/centos/6.10/os/x86_64/Packages/perl-devel-5.10.1-144.el6.x86_64.rpm
#wget -N http://rpmfind.net/linux/centos/6.10/os/x86_64/Packages/perl-5.10.1-144.el6.x86_64.rpm

tar -xf hmmer.tar.gz
tar -xf clustalw-2.1.tar.gz
tar -xf wise2.4.1.tar.gz
#tar -xf perl-5.28.0.tar.gz

rpm2cpio mafft-7.407-gcc_fc6.x86_64.rpm | cpio -idm
#rpm2cpio perl-devel-5.10.1-144.el6.x86_64.rpm | cpio -idm
#rpm2cpio perl-5.10.1-144.el6.x86_64.rpm | cpio -idm
mv usr/* ${main}/build
rm -rf usr

# move usearch
if ls ${main}/usearch* 1> /dev/null 2>&1 ; then
    cp ${main}/usearch11.0.667_i86linux32 ${main}/build/bin/usearch
    cp ${main}/usearch ${main}/build/bin/usearch

    chmod +x ${main}/build/bin/usearch
    
    echo " "
    echo "usearch is found!"
else
    echo " "
    echo " "
    echo "ERROR: Please download usearch in this directory"
    echo "Link to usearch website: https://drive5.com/usearch/"
    exit 1
fi

cd ${make}/downloads

cd hmmer-3.2.1
./configure --prefix=${main}/build
make
make install

cd ..

cd clustalw-2.1
./configure --prefix=${main}/build
make
make install

#cd ..

#cd perl-5.28.0
#./configure.gnu --prefix=${main}/build
#make
#make install

export PATH=$PATH:${main}/build/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${main}/build/lib

cd ..

cd wise2.4.1/src
find ./ -name makefile |xargs sed -i -e 's/glib-config/pkg-config --libs glib-2.0/g'
find ./ -name makefile |xargs sed -i -e 's/CC = cc/CC = gcc/g'
cd ./HMMer2
sed -i -e 's/getline/getLine/g' sqio.c
cd ../models
sed -i -e 's/isnumber/isdigit/g' phasemodel.c
cd ..
make all

make perl

export PATH=$PATH:$PWD/bin
export WISECONFIGDIR=${main}/downloads/wise2.4.1/wisecfg
make test

cd ${main}

#export PATH=$PATH:${main}/build/bin

cd ${main}/hamstr_build/bin
./configure


