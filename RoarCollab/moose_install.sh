#!/bin/bash
# Script to install Moose with PETSc and libtiprc 1.3.3
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 28 2023
# Updated: Mar 15 2023

module purge
module load cmake
module load python

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"


BASE=$PWD
mkdir -p $BASE/moosetmp
TMPDIR=$BASE/moosetmp

cd $TMPDIR
wget -nc https://sourceforge.net/projects/libtirpc/files/libtirpc/1.3.3/libtirpc-1.3.3.tar.bz2
tar -xf libtirpc-1.3.3.tar.bz2
cd libtirpc-1.3.3
CC=gcc CXX=g++ ./configure --prefix=$BASE/libtirpc_build
make -j $NP
make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASE/libtirpc_build/lib
export CPATH=$CPATH:$BASE/libtirpc_build/include/tirpc

tee $HOME/.moose_profile <<EOF
export CC=mpicc
export CXX=mpicxx
export F90=mpif90
export F77=mpif77
export FC=mpif90
EOF
source $HOME/.moose_profile

cd $BASE

# download Moose
git clone https://github.com/idaholab/moose.git
BUILD_DIR=$BASE/moose
cd moose
git checkout master

# install PETSc
cd $BUILD_DIR
unset PETSC_DIR PETSC_ARCH
./scripts/update_and_rebuild_petsc.sh --download-mpich

cd petsc
make PETSC_DIR=$BUILD_DIR/scripts/../petsc PETSC_ARCH=arch-moose check

export PETSC_DIR=$BUILD_DIR/petsc
export PETSC_ARCH=arch-moose
export PATH=$PATH:$BUILD_DIR/petsc/arch-moose/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/petsc/arch-moose/lib
export CPATH=$CPATH:$BUILD_DIR/petsc/arch-moose/include

cd $BUILD_DIR

# Remove below:
# cat << EOF > $BASE/tmpFILE

# sed -i -e '47756s|""|"-I'$BASE'/libtirpc_build/include/tirpc"|' $BUILD_DIR/libmesh/configure 
# sed -i -e '47757s|""|"-L'$BASE'/libtirpc_build/lib"|' $BUILD_DIR/libmesh/configure
# sed -i '47921d;47962d;47964d;47965d;47967d' $BUILD_DIR/libmesh/configure
# git submodule update --init --recursive

# EOF
# #sed -i -e '176 r '$BASE'/tmpFILE' $BUILD_DIR/scripts/update_and_rebuild_libmesh.sh

# rm $BASE/tmpFILE

PETSC_DIR=$BUILD_DIR/petsc CPPFLAGS="-I$BASE/libtirpc_build/include/tirpc -I$BUILD_DIR/petsc/arch-moose/include -I$BUILD_DIR/petsc/include" LDFLAGS="-L$BASE/libtirpc_build/lib -L$BUILD_DIR/petsc/arch-moose/lib" ./scripts/update_and_rebuild_libmesh.sh

export PATH=$PATH:$BUILD_DIR/libmesh/installed/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/libmesh/installed/lib
export CPATH=$CPATH:$BUILD_DIR/libmesh/installed/include

cd $BUILD_DIR/test
make -j $NP
./run_tests -j $NP


# Add envrionment variables to a file:
module purge 
cat << EOF > ~/.moose_profile
export CC=mpicc
export CXX=mpicxx
export F90=mpif90
export F77=mpif77
export FC=mpif90
export PATH=$PATH
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH
export CPATH=$CPATH
export PETSC_DIR=$PETSC_DIR
export PETSC_ARCH=$PETSC_ARCH
EOF

echo ""
echo "To use moose, use following command (or add in job script):"
echo "source ~/.moose_profile"


## Test:
#$BUILD_DIR/test/moose_test-opt -i $BUILD_DIR/test/tests/kernels/simple_diffusion/simple_diffusion.i -allow-test-objects
