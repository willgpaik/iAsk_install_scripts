#!/bin/bash
# Script to install sqlite3 3.41.2, libtiff 3.6.1, udunits2 2.2.26, gdal 3.6.3, geos 3.11.2, and proj 9.1.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Apr 12 2023
# This script will install raster package as well

module purge
module use /storage/icds/RISE/sw8/modules/
module load python
module load hdf5
module load netcdf
module load cmake
module load r/4.3.0

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

mkdir -p $HOME/R/x86_64-pc-linux-gnu-library/4.3

BASE=$PWD
cd ~/scratch
mkdir -p tmp_lib
cd tmp_lib
TMPDIR=~/scratch/tmp_lib

# Install udunits2
wget -nc https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/u/udunits2-2.2.26-5.el8.x86_64.rpm
wget -nc https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/u/udunits2-devel-2.2.26-5.el8.x86_64.rpm
rpm2cpio udunits2-2.2.26-5.el8.x86_64.rpm | cpio -idm
rpm2cpio udunits2-devel-2.2.26-5.el8.x86_64.rpm | cpio -idm

cd $TMPDIR

mv ./usr ~/work/rgdal_dep
BUILD_DIR=~/work/rgdal_dep
ln -s $BUILD_DIR/lib64/libudunits2.so.0 $BUILD_DIR/lib64/libudunits2.so

cd $TMPDIR 

# Install SQLite 3.41.2
wget -nc https://www.sqlite.org/2023/sqlite-autoconf-3410200.tar.gz
tar -xf sqlite-autoconf-3410200.tar.gz
cd sqlite-autoconf-3410200
./configure --prefix=$BUILD_DIR --enable-rtree --enable-session
make -j $NP && make install


cd $TMPDIR
# Install libtiff
wget -nc https://download.osgeo.org/libtiff/tiff-4.5.0rc3.tar.xz
tar -xf tiff-4.5.0rc3.tar.xz
cd tiff-4.5.0
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64
export CPATH=$CPATH:$BUILD_DIR/include:/usr/include
export CPLUS_INCLUDE_PATH=/usr/include/c++/8:$CPLUS_INCLUDE_PATH
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_DIR/lib/pkgconfig:$BUILD_DIR/lib64/pkgconfig
export PROJ_DATA=$BUILD_DIR/share/proj

cd $TMPDIR
# Install geos
wget -nc https://download.osgeo.org/geos/geos-3.11.2.tar.bz2
tar -xf geos-3.11.2.tar.bz2
cd geos-3.11.2
./configure --prefix=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR
# Install proj
mkdir -p proj_data
wget -nc https://download.osgeo.org/proj/proj-9.1.1.tar.gz
wget -nc https://download.osgeo.org/proj/proj-data-1.13.tar.gz
tar -xf proj-9.1.1.tar.gzc
tar -xf proj-data-1.13.tar.gz -C ./proj_data
cd proj-9.1.1
mkdir -p build && cd build
cmake .. --fresh -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DEXE_SQLITE3=$BUILD_DIR/bin/sqlite3 -DSQLITE3_INCLUDE_DIR=$BUILD_DIR/include -DSQLITE3_LIBRARY=$BUILD_DIR/lib/libsqlite3.so -DCMAKE_CXX_FLAGS="-I/usr/include" -DCMAKE_C_FLAGS="-I/usr/include" -DCMAKE_INSTALL_OLDINCLUDEDIR=$BUILD_DIR
cmake --build .
cmake --build . --target install
#make -j $NP && make install

cd $TMPDIR
# Install gdal
wget -nc https://github.com/OSGeo/gdal/releases/download/v3.6.3/gdal-3.6.3.tar.gz
tar -xf gdal-3.6.3.tar.gz
cd gdal-3.6.3
mkdir -p build
cd build
#cmake .. -DPROJ_DIR=$BUILD_DIR -DSQLITE3EXT_INCLUDE_DIR=/storage/icds/RISE/sw8/sqlite3/include -DSQLite3_INCLUDE_DIR=$BUILD_DIR/include -DSQLite3_LIBRARY=$BUILD_DIR/lib -DHDF_ENABLED=ON -DNETCDF_DIR=/swst/apps/netcdf-c/4.8.1_gcc-8.5.0 -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DINSTALL_PLUGIN_DIR=$BUILD_DIR/gdalplugins -DACCEPT_MISSING_SQLITE3_MUTEX_ALLOC:BOOL=ON
cmake .. -DHDF_ENABLED=ON -DNetCDF_DIR=/swst/apps/netcdf-c/4.8.1_gcc-8.5.0 -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DINSTALL_PLUGIN_DIR=$BUILD_DIR/gdalplugins -DSQLITE3EXT_INCLUDE_DIR=/storage/icds/RISE/sw8/sqlite3/include
cmake .. --fresh -DPROJ_DIR=$BUILD_DIR -DSQLITE3EXT_INCLUDE_DIR=$BUILD_DIR/include -DSQLite3_INCLUDE_DIR=$BUILD_DIR/include -DSQLite3_LIBRARY=$BUILD_DIR/lib/libsqlite3.so -DHDF_ENABLED=ON -DNETCDF_DIR=/swst/apps/netcdf-c/4.8.1_gcc-8.5.0 -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DINSTALL_PLUGIN_DIR=$BUILD_DIR/gdalplugins -DACCEPT_MISSING_SQLITE3_MUTEX_ALLOC:BOOL=ON
make -j $NP && make install


cd $BASE

rm -rf $TMPDIR

R --vanilla << EOF
install.packages("units", configure.args = "--with-udunits2-lib=$BUILD_DIR/lib64 --with-udunits2-include=$BUILD_DIR/include/udunits2 udunits2=$BUILD_DIR/include", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")
install.packages("sf", configure.args = "--with-sqlite3-lib=$BUILD_DIR/lib/libsqlite3.so --with-gdal-config=$BUILD_DIR/bin/gdal-config --with-gdal-lib=$BUILD_DIR/lib64/libgdal.so --with-proj-lib=$BUILD_DIR/lib64/libproj.so --with-proj-include=$BUILD_DIR --with-proj-share=$BUILD_DIR/share/proj --with-geos-config=$BUILD_DIR/bin/geos-config LDFLAGS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' CPPFLAGS=-I$BUILD_DIR/include", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")
install.packages("rgdal", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")
install.packages("terra", configure.args = "--with-sqlite3-lib=$BUILD_DIR/lib --with-gdal-config=$BUILD_DIR/bin/gdal-config --with-proj-lib=$BUILD_DIR/lib64 --with-proj-include=$BUILD_DIR/include --with-proj-share=$BUILD_DIR/share/proj --with-geos-config=$BUILD_DIR/bin/geos-config LDFLAGS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' CPPFLAGS=-I$BUILD_DIR/include", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")
install.packages("raster", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")
q()
EOF


# Add to bashrc
if [[ -f $BUILD_DIR/bin/gdalinfo ]]; then
	echo "rgdal is successfully installed!"
	module purge
	echo "# ##### rgdal >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> ~/.bashrc
	echo "export CPATH=$CPATH" >> ~/.bashrc
	echo "export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH" >> ~/.bashrc
	echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> ~/.bashrc
	echo "export PROJ_LIB=$PROJ_LIB" >> ~/.bashrc
	echo "# <<<<< rgdal #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "rgdal installation failed!"
fi
