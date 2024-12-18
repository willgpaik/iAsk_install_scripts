mkdir -p $PWD/emsoft
mkdir -p $PWD/emtmp

BASE=$PWD
BUILDDIR=$BASE/emsoft
TMPDIR=$BASE/emtmp

cd $TMPDIR

# install EMsoft SDK
wget https://github.com/EMsoft-org/EMsoftSuperbuild/archive/v5.0.0.tar.gz
tar -xf v5.0.0.tar.gz 
cd EMsoftSuperbuild-5.0.0/
sed -i '59 a -DCMAKE_Fortran_COMPILER=/opt/rh/devtoolset-8/root/usr/bin/gfortran' ./projects/JsonFortran.cmake
mkdir build
cd build
# emsoft workbench is disabled to make life easier:
# https://github.com/EMsoft-org/EMsoftSuperbuild/issues/11
cmake .. -DEMsoft_SDK=$BUILDDIR/EMsoft_SDK -DCMAKE_BUILD_TYPE=Release -DEMsoft_ENABLE_EMsoftWorkbench=OFF
make -j 2

cd $TMPDIR

cd $BUILDDIR
git clone https://github.com/EMsoft-org/EMsoftData.git
cd EMsoftData
git pull origin develop

sed -i "s|lib/cmake/jsonfortran-gnu-4.2.1|lib64/cmake/jsonfortran-gnu-4.2.1|g" $BUILDDIR/EMsoft_SDK/EMsoft_SDK.cmake

cd $TMPDIR

# install EMsoft
#rm v5.0.0.tar.gz
#wget https://github.com/EMsoft-org/EMsoft/archive/v5.0.0.tar.gz
#tar -xf v5.0.0.tar.gz
#cd EMsoft-5.0.0/
git clone https://github.com/EMsoft-org/EMsoft.git
cd EMsoft
sed -i "s|git@github.com:EMsoft-org/SHTfile.git|https://github.com/EMsoft-org/SHTfile.git|g" CMakeLists.txt
sed -i "s|https://github.com/emsoft-org/EMsoftData|https://github.com/EMsoft-org/EMsoftData.git|g" Source/Test/CMakeLists.txt
mkdir build
cd build
cmake .. -DEMsoft_SDK=$BUILDDIR/EMsoft_SDK -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DEMsoft_ENABLE_EMsoftWorkbench=OFF -DEMsoftData_DIR=$BUILDDIR/EMsoftData
make -j 2
make install

cd $BASE
rm -rf $TMPDIR
