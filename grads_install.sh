#!/bin/bash
# Script to install GrADS 2.2.1 with dependencies
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 25 2020

module purge
module load gcc/5.3.1

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p grads
mkdir -p grads_tmp

BUILD_DIR=$PWD/grads
TMPDIR=$PWD/grads_tmp

cd $TMPDIR
# Download dependencies
wget ftp://cola.gmu.edu/grads/Supplibs/2.2/builds/supplibs-rhel6.4-x86_64.tar.gz
tar -xf supplibs-rhel6.4-x86_64.tar.gz
cd supplibs
mv ./* $BUILD_DIR

cd $BUILD_DIR/lib
for i in *.la
do
	sed -i -e "s|/glade/u/home/jennifer/rhel-6.4/supplibs|$BUILD_DIR|g" $i
done

cd $BUILD_DIR/lib/pkgconfig
for i in *.pc
do
	sed -i -e "s|/glade/u/home/jennifer/rhel-6.4/supplibs|$BUILD_DIR|g" $i
done


export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_DIR/lib/pkgconfig
export SUPPLIBS=$BUILD_DIR


cd $TMPDIR
# Install GrADS 2.2.1
wget ftp://cola.gmu.edu/grads/2.2/grads-2.2.1-src.tar.gz
tar -xf grads-2.2.1-src.tar.gz
cd grads-2.2.1
./configure --prefix=$BUILD_DIR
make && make install


cd $BUILD_DIR
# Add to bashrc
if [[ -f $BUILD_DIR/bin/grads ]]; then
	echo "GrADS is successfully installed!"
	module purge
	read -p 'Do you want to add environment variables to your bashrc? (yes/no) ' CHECK
	if [[ $CHECK == 'yes' || $CHECK == 'y' ]]; then
		echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
		echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc
		echo "Please type: source ~/.bashrc"
	else
		echo "Please use commands below before using GrADS:"
		echo "export PATH=$PATH:$PWD/bin"
		echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/lib"
	fi

else
	echo "GrADS installation failed!"
fi


cd $BASE
rm -rf $TMPDIR
