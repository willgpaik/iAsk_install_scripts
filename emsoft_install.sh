
module load python/2.7.14-anaconda5.0.1
# CANNOT use Python3 -> UnicodeDecodeError: 'ascii' codec can't decode byte 0xe2 in position 269789: ordinal not in range(128)
module load gcc/5.3.1
module load openmpi
module load blas
module load lapack

mkdir -p $PWD/emsoft
mkdir -p $PWD/emtmp
mkdir -p $PWD/cmake_build

BASE=$PWD
BUILDDIR=$BASE/emsoft
TMPDIR=$BASE/emtmp
CMAKEDIR=$BASE/cmake_build

export PATH=$PATH:$BUILDDIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILDDIR/lib:$BUILDDIR/lib64
export CPATH=$CPATH:$BUILDDIR/include

cd $TMPDIR
wget https://github.com/Kitware/CMake/releases/download/v3.15.5/cmake-3.15.5.tar.gz
wget http://bitbucket.org/eigen/eigen/get/3.3.7.tar.bz2
git clone https://github.com/jacobwilliams/json-fortran.git
git clone https://github.com/cass-support/clfortran.git
wget https://github.com/szaghi/FoBiS/archive/v2.9.5.tar.gz
git clone https://github.com/EMsoft-org/EMsoftSuperbuild.git

wget http://repo.okay.com.mx/centos/6/x86_64/release//libopencl1-2.2.9-1.el6.x86_64.rpm
wget http://repo.okay.com.mx/centos/6/x86_64/release//libopencl-devel-2.2.9-1.el6.x86_64.rpm
rpm2cpio libopencl1-2.2.9-1.el6.x86_64.rpm | cpio -idmv
rpm2cpio libopencl-devel-2.2.9-1.el6.x86_64.rpm | cpio -idmv
mv ./usr/* $BUILDDIR

# install Cmake
tar -xf cmake-3.15.5.tar.gz
cd cmake-3.15.5
./configure --prefix=$CMAKEDIR
make && make install

cd $TMPDIR

# install Eigen 3.3.7
tar -xf 3.3.7.tar.bz2
cd eigen-eigen-323c052e1731
mkdir build
cd build
$CMAKEDIR/bin/cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR
make install

cd $TMPDIR

# install CLFortran
cd clfortran
sed -i "s|/usr/lib64/catalyst|${BUILDDIR}/lib64|g" ./Makefile
make
mkdir -p $BUILDDIR/bin
cp basic_device_io $BUILDDIR/bin
cp create_device_context $BUILDDIR/bin
cp query_platforms_devices $BUILDDIR/bin

cd $TMPDIR

# install FoBiS for json-fortran
#tar -xf v2.9.5.tar.gz 
#cd FoBiS
#cd FoBiS-2.9.5/release/FoBiS-master
#python3 setup.py install --user
#export PATH=$PATH:~/.local/bin

cd $TMPDIR

# install json-fortran
pip install FORD --user
cd json-fortran
mkdir build
cd build
$CMAKEDIR/bin/cmake .. -DCMAKE_INSTALL_PREFIX=$BUILDDIR -DCMAKE_Fortran_COMPILER=/opt/rh/devtoolset-4/root/usr/bin/gfortran
make && make install

export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILDDIR/jsonfortran-gnu-7.1.0/lib

cd $TMPDIR




wget http://download-ib01.fedoraproject.org/pub/epel/6/x86_64/Packages/q/qt5-qtsvg-5.6.1-2.el6.x86_64.rpm
rpm2cpio qt5-qtsvg-5.6.1-2.el6.x86_64.rpm | cpio -idmv
mv ./usr/* $BUILDDIR

# install EMsoft SDK
wget https://github.com/EMsoft-org/EMsoftSuperbuild/archive/v5.0.0.tar.gz
tar -xf v5.0.0.tar.gz 
cd EMsoftSuperbuild-5.0.0/
mkdir build
cd build
$CMAKEDIR/bin/cmake .. -DEMsoft_SDK=$BUILDDIR/EMsoft_SDK -DCMAKE_BUILD_TYPE=Release -DINSTALL_QT5=ON
make
sed -i "s|/usr/bin/f95|/opt/rh/devtoolset-4/root/usr/bin/gfortran|g" $BUILDDIR/EMsoft_SDK/superbuild/jsonfortran/Build/Release/CMakeCache.txt
make && make

cd $TMPDIR


# install EMsoft
rm v5.0.0.tar.gz
wget https://github.com/EMsoft-org/EMsoft/archive/v5.0.0.tar.gz
tar -xf v5.0.0.tar.gz
cd EMsoft-5.0.0/
sed -i "s|git@github.com:EMsoft-org/SHTfile.git|https://github.com/EMsoft-org/SHTfile.git|g" CMakeLists.txt
mkdir build
cd build
$CMAKEDIR/bin/cmake .. -DEMSoft_SDK=$BUILDDIR/EMsoft_SDK -DCMAKE_BUILD_TYPE=Release -DHDF5_DIR=$BUILDDIR/EMsoft_SDK/hdf5-1.8.20-Release/share/cmake -Djsonfortran-gnu_DIR=$BUILDDIR/EMsoft_SDK/jsonfortran-4.2.1-Release/lib64/cmake/jsonfortran-gnu-4.2.1/ -DFFTW3_INSTALL=$BUILDDIR/EMsoft_SDK/fftw-3.3.8 -DOpenCL_LIBRARY=$BUILDDIR/lib64 -DOpenCL_INCLUDE_DIR=$BUILDDIR/include -DCLFortran_DIR=$BUILDDIR/EMsoft_SDK/CLFortran-0.0.1-Release/lib/cmake/CLFortran -DQt5Svg_DIR=$BUILDDIR/lib64










/gpfs/scratch/gip5038/test/emsoft/cmake_build/bin/cmake .. -DEMSoft_SDK=/storage/home/gip5038/scratch/test/emsoft/emsoft/EMsoft_SDK/ -DCMAKE_BUILD_TYPE=Release -DHDF5_DIR=/storage/home/gip5038/scratch/test/emsoft/emsoft/EMsoft_SDK/hdf5-1.8.20-Release/share/cmake/ -Djsonfortran-gnu_DIR=/storage/home/gip5038/scratch/test/emsoft/emsoft/EMsoft_SDK/jsonfortran-4.2.1-Release/lib64/cmake/jsonfortran-gnu-4.2.1 -DFFTW3_INSTALL=/storage/home/gip5038/scratch/test/emsoft/emsoft/EMsoft_SDK/fftw-3.3.8/ -DOpenCL_LIBRARY=/storage/home/gip5038/scratch/test/emsoft/emsoft/lib64/ -DOpenCL_INCLUDE_DIR=/storage/home/gip5038/scratch/test/emsoft/emsoft/include/ -DCLFortran_DIR=/storage/home/gip5038/scratch/test/emsoft/emsoft/EMsoft_SDK/CLFortran-0.0.1-Release/lib/cmake/CLFortran/ -DQt5Svg_DIR=/storage/home/gip5038/scratch/test/emsoft/emsoft/lib64/


bcls-0.1-Release/lib/cmake/bcls


