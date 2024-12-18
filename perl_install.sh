#!/bin/bash
# Script to install ncview with Perl 5.28.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 22 2019

BASE=$PWD
mkdir -p perl_build
mkdir -p perltmp
BUILD_DIR=$BASE/perl_build
TMPDIR=$BASE/perltmp

cd $TMPDIR
wget https://www.cpan.org/src/5.0/perl-5.28.1.tar.gz
tar -xf perl-5.28.1.tar.gz
cd perl-5.28.1
./configure.gnu --prefix=$BUILD_DIR
make
make install

cd $BASE
rm -rf perltmp

echo "export PATH=$BUILD_DIR/bin:$PATH" >> ~/.bashrc
