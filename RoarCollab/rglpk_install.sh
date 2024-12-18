#!/bin/bash
# Script to install glpk 5.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Aug 25 2023

module purge
module load r

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p glpk
mkdir -p glpk_tmp

BUILD_DIR=$PWD/glpk
TMPDIR=$PWD/glpk_tmp

cd $TMPDIR
# Install glpk 5.0
wget -nc https://ftp.gnu.org/gnu/glpk/glpk-5.0.tar.gz
tar -xf glpk-5.0.tar.gz
cd glpk-5.0
./configure --prefix=$BUILD_DIR
make -j $NP
make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib
export CPATH=$LD_LIBRARY_PATH:$BUILD_DIR/include

cd $TMPDIR
wget -nc https://cran.r-project.org/src/contrib/Rglpk_0.6-5.tar.gz
tar -xf Rglpk_0.6-5.tar.gz
cd Rglpk/src
cp -R $TMPDIR/glpk-5.0 GLPK

R --vanilla << EOF
install.packages("$TMPDIR/Rglpk", repos=NULL, configure.args="-L/$BUILD_DIR/lib")
q()
EOF


# Add to bashrc
if [[ -f $BUILD_DIR/bin/glpsol ]]; then
	echo "glpk is successfully installed!"
	module purge
	echo "# ##### glpk >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc
	echo "export LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib" >> ~/.bashrc
	echo "export CPATH=$LD_LIBRARY_PATH:$BUILD_DIR/include" >> ~/.bashrc
	echo "# <<<<< glpk #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "glpk installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
