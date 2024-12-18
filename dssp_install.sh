#!/bin/bash
# Script to install DSSP with boost 1.70.0, autoconf 2.65, automake 1.15.1, and libzeep
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 25 2019
# Updated: July 18 2019
# NOTE: NOT TESTED due to server down (gnu.org)

module load gcc
#module load boost

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

BASE=$PWD
mkdir -p $BASE/dssp_tmp
mkdir -p $BASE/dssp
mkdir -p $BASE/boost_build
TMPDIR=$BASE/dssp_tmp
BUILD_DIR=$BASE/dssp

cd $TMPDIR

# Install Boost 1.70.0
wget https://dl.bintray.com/boostorg/release/1.70.0/source/boost_1_70_0.tar.gz
tar -xf boost_1_70_0.tar.gz
cd boost_1_70_0
./bootstrap.sh --prefix=$BASE/boost_build
./b2 -j $NP install

export BOOST_ROOT=$BASE/boost_build
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASE/boost_build/lib
export CPATH=$CPATH:$BASE/boost_build/include

cd $TMPDIR

# Install b2 (Boost installer)
git clone https://github.com/boostorg/build.git
cd build
./bootstrap.sh
./b2 -j $NP install --prefix=$BASE/boost_build

export PATH=$PATH:$BOOST_ROOT/bin

cd $TMPDIR

# Install autoconf 2.69
wget http://ftp.gnu.org/gnu/autoconf/autoconf-2.69.tar.gz
tar -xf autoconf-2.69.tar.gz
cd autoconf-2.69
./configure --prefix=$BUILD_DIR
make -j $NP
make install

export PATH=$BUILD_DIR/bin:$PATH

cd $TMPDIR

# Install automake 1.15.1
wget http://ftp.gnu.org/gnu/automake/automake-1.15.1.tar.gz
tar -xf automake-1.15.1.tar.gz
cd automake-1.15.1
./configure --prefix=$BUILD_DIR
make -j $NP && make install

cd $BASE

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASE/libzeep/lib:/lib:/lib64
export CPATH=$CPATH:$BASE/libzeep/include/zeep

git clone https://github.com/mhekkel/libzeep.git
cd libzeep
# BELOW ONLY WORKS ON MAY 12 2019 VERSION OR EARLIER
#sed -i -e 's|#BOOST              = $(HOME)/projects/boost|BOOST=$(BOOST_ROOT)|g' makefile
#sed -i -e 's|PREFIX              ?= /usr/local|PREFIX=$(BUILD_DIR)|g' makefile
#sed -i -e 's/bjam/b2/g' makefile
# NEW FIX:
sed -i -e '23s/-g/-g $(BOOST_LIB_DIR:%=-L%)/g' makefile
sed -i -e '23s/-g/-g $(BOOST_LIB_DIR:%=-L%)/g' ./lib/makefile
sed -i -e '23s/-g/-g $(BOOST_LIB_DIR:%=-L%)/g' ./examples/makefile
sed -i -e '23s/-g/-g $(BOOST_LIB_DIR:%=-L%)/g' ./test/makefile
sed -i -e 's|# BUILD_SHARED_LIB = $(BUILD_SHARED_LIB)|BUILD_SHARED_LIB = 1|g' makefile
sed -i -e 's|# BOOST = $(HOME)/my-boost|BOOST = $(BOOST_ROOT)|g' makefile
sed -i -e 's|BOOST_LIB_DIR       = $(BOOST:%=%/lib)|BOOST_LIB_DIR       = $(BOOST_ROOT)/lib|g' makefile
sed -i -e 's|BOOST_INC_DIR       = $(BOOST:%=%/include)|BOOST_INC_DIR       = $(BOOST_ROOT)/include|g' makefile
make -j $NP
#make install

cd $TMPDIR

git clone https://github.com/cmbi/xssp.git
cd xssp
./autogen.sh
./configure --prefix=$BUILD_DIR/ --with-boost=$BOOST_ROOT/ --with-boost-libdir=$BOOST_ROOT/lib CPPFLAGS="-I${BOOST_ROOT}/include -I${BASE}/libzeep/include/zeep" LDFLAGS="-L${BOOST_ROOT}/lib -L${BASE}/libzeep/lib" CFLAGS=-lrt CXXFLAGS=-lrt
make -j $NP && make install

cd $BASE
rm -rf dssp_tmp



# https://stackoverflow.com/questions/19901934/libpthread-so-0-error-adding-symbols-dso-missing-from-command-line
# https://github.com/Bumblebee-Project/Bumblebee/issues/76
