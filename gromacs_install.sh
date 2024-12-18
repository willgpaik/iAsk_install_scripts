# This script installs GROMACS 2019 ver. without CUDA
# GCC 5.3.1 and OpenMPI is required as well as CMAKE
# Script written by: Will Paik (gip5038)
# Jan 28 2019
# Last updated: May 23 2019 by Will
# Use fftw module -> avoid cufft related issue

module load gcc/5.3.1 openmpi cmake fftw

BASE=$PWD

# Check existence of directory
if [[ -d ${BASE}/gromacs2019_install ]] ; then
	echo "GROMACS 2019 is already installed"
	echo "Please delete gromacs2019_install and try again"
	break
fi

mkdir -p ${BASE}/gromacs2019_install

mkdir -p ${BASE}/src/tarballs
cd ${BASE}/src/tarballs
wget -nc http://ftp.gromacs.org/pub/gromacs/gromacs-2019.tar.gz
tar -xf gromacs-2019.tar.gz -C ..
cd ${BASE}/src
cd gromacs-2019
mkdir build && cd build
cmake -DGMX_BUILD_OWN_FFTW=OFF -DGMX_MPI=on -DGMX_SIMD=AVX_256 -DCMAKE_INSTALL_PREFIX=${BASE}/gromacs2019_install ..
make
make check
make install

src_cmd="source ${BASE}/gromacs2019_install/bin/GMXRC"

sed -i '/gromacs2019_install/d' $HOME/.bashrc

echo ${src_cmd} >> $HOME/.bashrc

source $HOME/.bashrc

if [[ -f "$(which GMXRC)" ]] ; then
	echo "GROMACS 2019 is successfully installed"
else
	echo "Please delete all previously installed files/directories and run it again"
fi 


