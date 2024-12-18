#!/bin/bash
# Script to install OpenFOAM 5.x with all dependencies (links may require updates)
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Created: May 20 2018
# Updated: Jan 15 2021

# Entire installation process takes over 3 hours on scivybridge
# Installation requires over 12 GB of empty space and 400,000 Inodes
# Default installation directory is $HOME/work
# In case you want to change the installation directory,
# please change paths on line 17, 73, and 76
# echo "alias of5x='source $HOME/scratch/OpenFOAM/OpenFOAM-5.x/etc/bashrc $FOAM_SETTINGS'"

# Strongly suggest working on an interactive job
# qsub -A open -I -l nodes=1:ppn=20:scivybridge -l walltime=6:00:00

set +e

module use /gpfs/group/RISE/sw7/modules
module load gcc/8.3.1
module load openmpi/3.1.6
module load python
module load cmake/3.18.4


# Change path to directory if needed
WORK=$HOME/scratch
mkdir -p $WORK/OpenFOAM
BASE=$WORK/OpenFOAM
WM_PROJECT=OpenFOAM-5.x

sed -i '/alias of5x/d' $HOME/.bashrc
sed -i '/of5x/d' $HOME/.bashrc

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo Number of threads used for installation: $NP

# Download files
cd $BASE
git clone https://github.com/OpenFOAM/OpenFOAM-5.x.git
git clone https://github.com/OpenFOAM/ThirdParty-5.x.git

sed -i -e 's|FOAM_INST_DIR=$HOME/$WM_PROJECT|FOAM_INST_DIR=$BASE/$WM_PROJECT|g' ${BASE}/${WM_PROJECT}/etc/bashrc

cd ThirdParty-5.x
if [[ ! -d "./download" ]]; then
	mkdir -p download
	#wget -nc -P download https://www.cmake.org/files/v3.9/cmake-3.9.0.tar.gz
	wget -nc -P download https://github.com/CGAL/cgal/releases/download/releases%2FCGAL-4.10/CGAL-4.10.tar.xz
	wget -nc -P download https://sourceforge.net/projects/boost/files/boost/1.55.0/boost_1_55_0.tar.bz2
	wget -nc -P download https://www.open-mpi.org/software/ompi/v2.1/downloads/openmpi-2.1.1.tar.bz2
	wget -nc -P download http://www.paraview.org/files/v5.4/ParaView-v5.4.0.tar.gz

	#tar -xzf download/cmake-3.9.0.tar.gz
	tar -xJf download/CGAL-4.10.tar.xz
	tar -xjf download/boost_1_55_0.tar.bz2
	tar -xjf download/openmpi-2.1.1.tar.bz2
	tar -xzf download/ParaView-v5.4.0.tar.gz --transform='s/ParaView-v5.4.0/ParaView-5.4.0/'

	wget -nc -P download http://mirror.centos.org/centos/7/updates/x86_64/Packages/qt-assistant-4.8.7-9.el7_9.x86_64.rpm
	rpm2cpio ./download/qt-assistant-4.8.7-9.el7_9.x86_64.rpm | cpio -idmv
	wget -nc -P download https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/ptscotch-openmpi-6.0.4-13.el7.x86_64.rpm
	rpm2cpio ./download/ptscotch-openmpi-6.0.4-13.el7.x86_64.rpm | cpio -idmv
	wget -nc -P download https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/p/ptscotch-openmpi-devel-6.0.4-13.el7.x86_64.rpm
	rpm2cpio ./download/ptscotch-openmpi-devel-6.0.4-13.el7.x86_64.rpm | cpio -idmv
	wget -nc -P download https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/s/scotch-6.0.4-13.el7.x86_64.rpm
	rpm2cpio ./download/scotch-6.0.4-13.el7.x86_64.rpm | cpio -idmv
	wget -nc -P download/https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/s/scotch-devel-6.0.4-13.el7.x86_64.rpm
	rpm2cpio ./download/scotch-devel-6.0.4-13.el7.x86_64.rpm

	
	#wget -nc -P download https://gitlab.inria.fr/scotch/scotch/-/archive/v6.0.6/scotch-v6.0.6.tar.gz
	#tar -xzf download/scotch-v6.0.6.tar.gz
	sed -i '0,/prefix/s/prefix.*/prefix=${PWD}/' scotch-v6.0.6/src/Makefile
	ln -s Make.inc/Makefile.inc.x86-64_pc_linux2.shlib scotch-v6.0.6/src/Makefile.inc
	cd scotch-v6.0.6/src
	make -j $NP ptscotch && make install
	make -j $NP scotch && make install

	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$PWD/scotch-v6.0.6/lib
	export CPATH=$CPATH:$PWD/scotch-v6.0.6/include
	export CFLAGS=-I$PWD/scotch-v6.0.6/include
	export CPPFLAGS=-I$PWD/scotch-v6.0.6/include
	export PATH=$PATH:$PWD/scotch-v6.0.6/bin
fi

cd $BASE

echo Files are downloaded and extracted

sed -i -e 's/\(boost_version=\)boost-system/\1boost_1_55_0/' OpenFOAM-5.x/etc/config.sh/CGAL
sed -i -e 's/\(cgal_version=\)cgal-system/\1CGAL-4.10/' OpenFOAM-5.x/etc/config.sh/CGAL

#RHEL 7 version only support 64-bit
source $BASE/OpenFOAM-5.x/etc/bashrc WM_LABEL_SIZE=64 WM_MPLIB=OPENMPI FOAMY_HEX_MESH=yes
echo "alias of5x='source $BASE/OpenFOAM-5.x/etc/bashrc $FOAM_SETTINGS'" >> $HOME/.bashrc

source $HOME/.bashrc

#echo "of5x" >> $HOME/.bashrc

of5x

#echo Building CMAKE-3.x
#cd $WM_THIRD_PARTY_DIR
#./makeCmake > log.makeCmake 2>&1
#wmRefresh

# Setup OpenMPI for ParaView
cd $WM_THIRD_PARTY_DIR
./Allwmake > log.make 2>&1
wmRefresh

echo Building ParaView-5.4.0
echo This process may take few hours
# Build ParaView 5.4.0 with Python and MPI
cd $WM_THIRD_PARTY_DIR
#this will take a while... somewhere between 30 minutes to 2 hours or more
./makeParaView -mpi -python -python-lib /usr/lib64/libpython3.so -python-include /usr/include/python3.6m -qmake $(which qmake-qt4) > log.makePV 2>&1
wmRefresh


cd $WM_PROJECT_DIR
echo Building OpenFOAM-5.x
echo This process may take few hours


./Allwmake -j $NP > log.make 2>&1

# Run above again to get an installation summary
./Allwmake -j $NP > log.make 2>&1

# Check status of installation
of5x

echo $(which icoFoam)

CHK_COMPLETE=$(icoFoam -help)

if [[ -f $(which icoFoam) ]]; then
        icoFoam -help
        echo Installation is successfully completed!
else
        echo Could not successfully install OpenFOAM-5.x
fi

