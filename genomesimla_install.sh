#!/bin/bash
# Script to install genomesimla 1.1.3 with soci 4.0.3
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# June 28 2022

module purge
module use /gpfs/group/RISE/sw7/modules
module load gcc/8.3.1
module load boost/1.79.0
module load cmake/3.18.4

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p genomesimla
mkdir -p genomesimla_tmp

BUILD_DIR=$PWD/genomesimla
TMPDIR=$PWD/genomesimla_tmp

cd $TMPDIR
# Install soci 4.0.3
wget -nc https://sourceforge.net/projects/soci/files/soci/soci-4.0.3/soci-4.0.3.tar.gz
tar -xf soci-4.0.3.tar.gz
cd soci-4.0.3
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DSOCI_CXX11=ON 
make -j $NP && make install

export CPATH=$CPATH:$BUILD_DIR/include
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib64

cd $TMPDIR
# Install genomesimla 1.1.3
wget -nc https://ritchielab.org/files/RL_software/genomesimla-1.1.3.tar.gz
tar -xf genomesimla-1.1.3.tar.gz
cd genomesimla-1.1.3

# Fixed errors for installation (Cannot guarantee to work as intended)
# Fixed argument dependent lookup error (https://stackoverflow.com/a/15531940)
sed -i -e "225s/initializer/this->initializer/g" ./src/ga/GA1DArrayGenome.C
sed -i -e "226s/mutator/this->mutator/g" ./src/ga/GA1DArrayGenome.C
sed -i -e "241s/initializer/this->initializer/g" ./src/ga/GA1DArrayGenome.C
sed -i -e "242s/mutator/this->mutator/g" ./src/ga/GA1DArrayGenome.C

sed -i -e "272s/initializer/this->initializer/g" ./src/ga/GA2DArrayGenome.C
sed -i -e "273s/mutator/this->mutator/g" ./src/ga/GA2DArrayGenome.C
sed -i -e "289s/initializer/this->initializer/g" ./src/ga/GA2DArrayGenome.C
sed -i -e "290s/mutator/this->mutator/g" ./src/ga/GA2DArrayGenome.C

sed -i -e "325s/initializer/this->initializer/g" ./src/ga/GA3DArrayGenome.C
sed -i -e "326s/mutator/this->mutator/g" ./src/ga/GA3DArrayGenome.C
sed -i -e "342s/initializer/this->initializer/g" ./src/ga/GA3DArrayGenome.C
sed -i -e "343s/mutator/this->mutator/g" ./src/ga/GA3DArrayGenome.C

# Fixed conflicting return variable type error
sed -i -e "86s/false/NULL/g" ./src/genetics/familynode.cpp

# Fixed "M" variable conflict with Boost
sed -i -e "47s/M/M_SIMLA/g" ./src/simla/random.h
sed -i -e "446s/M/M_SIMLA/g" ./src/simla/random.cpp
sed -i -e "452s/M/M_SIMLA/g" ./src/simla/random.cpp
sed -i -e "455s/M/M_SIMLA/g" ./src/simla/random.cpp
sed -i -e "448s/M/M_SIMLA/g" ./src/simla/random.cpp
./configure --prefix=$BUILD_DIR --with-soci=$BUILD_DIR --with-boost=$BOOST_ROOT
make -j $NP && make install

cd $BASE

rm -rf $TMPDIR
