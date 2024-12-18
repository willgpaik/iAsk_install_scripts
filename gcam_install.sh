#!/bin/bash
# Script to install GCAM with Jar, Hector, Boost, and Xerces
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# August 23 2019

# In reference to ticket 32452

BASE=$PWD
############## create folders ##############
mkdir gcam_tmp
TMPDIR=$BASE/gcam_tmp
module load gcc/5.3.1
module load tbb/2017
module load mkl/11.3.3
JAVA_HOME=/usr/lib/jvm

############## download gcam ##############
git clone https://github.com/JGCRI/gcam-core.git
cd gcam-core
GCAM_WORKSPACE=$PWD
mkdir libs
mkdir libs/boost-lib
mkdir libs/boost-lib/stage
mkdir libs/boost-lib/stage/lib
mkdir libs/jars
mkdir libs/xercesc

############## download third party jars ##############
cd $GCAM_WORKSPACE/libs
wget https://github.com/JGCRI/modelinterface/releases/download/v5.1/jars.zip
unzip jars.zip && rm jars.zip

############## build Hector ##############
cd $GCAM_WORKSPACE
git submodule init cvs/objects/climate/source/hector
git submodule update cvs/objects/climate/source/hector

############## boost-numeric-bindings ##############
cd $GCAM_WORKSPACE/libs
git clone http://git.tiker.net/trees/boost-numeric-bindings.git
export BOOST_NUMERIC_BINDINGS=${GCAM_WORKSPACE}/libs/boost-numeric-bindings

############## Install xerces-c 3.2.2 ##############
cd $TMPDIR
wget http://apache.mirrors.lucidnetworks.net//xerces/c/3/sources/xerces-c-3.2.2.tar.gz
tar -xzvf xerces-c-3.2.2.tar.gz && rm xerces-c-3.2.2.tar.gz
cd xerces-c-3.2.2
./configure --prefix=$GCAM_WORKSPACE/libs/xercesc --disable-netaccessor-curl
make install

############## Install Boost 1.71.0 ##############
cd $TMPDIR
wget https://dl.bintray.com/boostorg/release/1.71.0/source/boost_1_71_0.tar.gz
tar -xzvf boost_1_71_0.tar.gz && rm boost_1_71_0.tar.gz
cd boost_1_71_0
./bootstrap.sh --prefix=$GCAM_WORKSPACE/libs/boost-lib/stage
./b2 install

############## build GCAM ##############
sed -i -e 's/-l$(LIBTBB) -l$(LIBTBBMALLOC) -l$(LIBTBBMALLOC_PROXY)/-l$(LIBTBB) -l$(LIBTBBMALLOC) -l$(LIBTBBMALLOC_PROXY) -lpthread/g' $GCAM_WORKSPACE/cvs/objects/build/linux/configure.gcam

export CXX=g++
export BOOST_INCLUDE=${GCAM_WORKSPACE}/libs/boost-lib/stage/include
export BOOST_LIB=${GCAM_WORKSPACE}/libs/boost-lib/stage/lib
export TBB_INCDIR=/opt/aci/sw/tbb/2017_gcc-5.3.1/include
export TBB_LIBDIR=/opt/aci/sw/tbb/2017_gcc-5.3.1/build/linux_intel64_gcc_cc5.3.1_libc2.12_kernel2.6.32_release
export XERCES_INCLUDE=${GCAM_WORKSPACE}/libs/xercesc/include
export XERCES_LIB=${GCAM_WORKSPACE}/libs/xercesc/lib
export JARS_LIB=${GCAM_WORKSPACE}/libs/jars/*
export JAVA_LIB=${JAVA_HOME}/jre-1.8.0-oracle.x86_64-1.8.0.131/lib/amd64/server
export JAVA_INCLUDE=${JAVA_HOME}/java-1.8.0-oracle-1.8.0.131.x86_64/include
export USE_GCAM_PARALLEL=1
export USE_LAPACK=1
export MKL_CFLAGS="-fopenmp -I${MKLROOT}/include"
export MKL_LIB=${MKLROOT}/lib/intel64
export MKL_LDFLAGS="-fopenmp -L${MKL_LIB} -lmkl_intel_lp64 -lmkl_core -lmkl_gnu_thread -ldl -lpthread -lm"
export MKL_RPATH="-Wl,rpath,${MKL_LIB}"
cd $GCAM_WORKSPACE/cvs/objects/build/linux && make gcam

############## testing ##############
#cd ${GCAM_WORKSPACE}/exe
#./gcam.exe -Cconfiguration_ref.xml

cd $BASE
rm -rf gcam_tmp
