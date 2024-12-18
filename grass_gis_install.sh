#!/bin/bash
# Script to install GRASS GIS 7.8.5 with XZ 5.2.5, libtiff 4.2.0, SQLite 3.35.2, proj 8.0.0, GDAL 3.2.2, and zstd 1.4.9
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Mar 17 2021
# GDAL install not working

module purge
module use /gpfs/group/dml129/default/sw/modules
module load cmake
module load gcc openmpi fftw netcdf/4.4.1

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p grass_gis
mkdir -p grass_gis_tmp

BUILD_DIR=$PWD/grass_gis
TMPDIR=$PWD/grass_gis_tmp

export LD_LIBRARY_PATH=$BUILD_DIR/lib:$BUILD_DIR/lib64:$LD_LIBRARY_PATH
export PATH=$BUILD_DIR/bin:$PATH
export CPATH=$BUILD_DIR/include:$CPATH

cd $TMPDIR
# Install XZ 5.2.5
wget -nc https://tukaani.org/xz/xz-5.2.5.tar.gz
tar -xf xz-5.2.5.tar.gz
cd xz-5.2.5
./configure --prefix=$BUILD_DIR
make -j $NP
make install

cd $TMPDIR
# Install libtiff 4.2.0
wget -nc https://download.osgeo.org/libtiff/tiff-4.2.0.tar.gz
tar -xf tiff-4.2.0.tar.gz
cd tiff-4.2.0
./configure --prefix=$BUILD_DIR
make -j $NP
make install


cd $TMPDIR
# Install SQLite 3.35.2
wget -nc https://www.sqlite.org/2021/sqlite-autoconf-3350200.tar.gz
tar -xf sqlite-autoconf-3350200.tar.gz
cd sqlite-autoconf-3350200
./configure --prefix=$BUILD_DIR
make -j $NP
make install

cd $TMPDIR
# Install proj 8.0.0
mkdir -p $BUILD_DIR/proj_data
wget -nc https://download.osgeo.org/proj/proj-data-1.5.tar.gz
tar -xf proj-data-1.5.tar.gz -C $BUILD_DIR/proj_data
wget -nc https://download.osgeo.org/proj/proj-8.0.0.tar.gz
tar -xf proj-8.0.0.tar.gz
cd proj-8.0.0
./configure --prefix=$BUILD_DIR SQLITE3_CFLAGS="-I$BUILD_DIR/include" SQLITE3_LIBS="-L$BUILD_DIR/lib -lsqlite3" TIFF_CLFAGS="-I$BUILD_DIR/include" TIFF_LIBS="-L$BUILD_DIR/lib -ltiff"
make -j $NP
make install

cd $TMPDIR
# Install GDAL 3.2.2
wget -nc https://github.com/OSGeo/gdal/releases/download/v3.2.2/gdal-3.2.2.tar.gz
tar -xf gdal-3.2.2.tar.gz
cd gdal-3.2.2
CPPFLAGS="-I$BUILD_DIR/include"
LDFLAGS="-L$BUILD_DIR/lib"
LIBS="-lproj -lsqlite3"
PKG_CONFIG=$BUILD_DIR/lib/pkgconfig
./configure --prefix=$BUILD_DIR --with-proj=$BUILD_DIR --with-proj-extra-lib-for-test=$BUILD_DIR/lib --with-sqlite3=$BUILD_DIR
make -j $NP
make install

cd $TMPDIR
# Install zstd 1.4.9
wget -nc https://github.com/facebook/zstd/archive/v1.4.9.tar.gz
tar -xf v1.4.9.tar.gz
cd zstd-1.4.9
make -j $NP
make install PREFIX=$BUILD_DIR

cd $TMPDIR

# Install GRASS GIS 7.8.5
wget -nc https://github.com/OSGeo/grass/archive/7.8.5.tar.gz
tar -xf 7.8.5.tar.gz
cd grass-7.8.5
./configure \
   --prefix=$BUILD_DIR \
   --enable-64bit --with-fftw \
   --with-netcdf --with-geos --with-blas --with-lapack --with-postgres \
   --with-zstd-includes=$BUILD_DIR/lib/ \
   --with-zstd-libs=$BUILD_DIR/lib/ \
   --with-gdal=$BUILD_DIR/bin/gdal-config \
   --with-proj-include=$BUILD_DIR/include --with-proj-libs=$BUILD_DIR/lib



cd $BASE

rm -rf $TMPDIR