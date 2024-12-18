#!/bin/bash
# Script to install SQLite 3.38.2, curl 7.82.0, udunits2 2.2.20, gdal 3.4.2, geos 3.10.2, proj 9.0.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Oct 19 2020
# Last updated: Jul 27 2022

# Taken from r_spdep_dependency_install_user.sh
# Installs dependencies on work directory (~500 MB)
# Packages for R 4.1
# Updated for RHEL 7

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

module purge
module use /gpfs/group/RISE/sw7/modules
module load hdf5/1.12.1-gcc-9.3.1
module load automake
module load cmake/3.18.4
module load r/4.1.2

cd ~/scratch
mkdir tmp_lib
cd tmp_lib
TMPDIR=~/scratch/tmp_lib

# "units" requires udunits2-devel
wget -nc https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/u/udunits2-2.2.20-2.el7.x86_64.rpm
wget -nc https://download-ib01.fedoraproject.org/pub/epel/7/x86_64/Packages/u/udunits2-devel-2.2.20-2.el7.x86_64.rpm

rpm2cpio udunits2-2.2.20-2.el7.x86_64.rpm | cpio -idmv
rpm2cpio udunits2-devel-2.2.20-2.el7.x86_64.rpm | cpio -idmv

cd $TMPDIR

mv ./usr ~/work/rgdal_dep
BUILD_DIR=~/work/rgdal_dep

#sed -i -e "s|prefix=/usr|prefix=$BUILD_DIR|g" $BUILD_DIR/lib64/pkgconfig/proj.pc
#sed -i -e "s|exec=/usr|exec=$BUILD_DIR|g" $BUILD_DIR/lib64/pkgconfig/proj.pc
#sed -i -e "s|libdir=/usr/lib|libdir=$BUILD_DIR/lib64|g" $BUILD_DIR/lib64/pkgconfig/proj.pc
#sed -i -e "s|includedir=/usr/include|includedir=$BUILD_DIR/include|g" $BUILD_DIR/lib64/pkgconfig/proj.pc

#cd $TMPDIR

# Install udunits 2.2.28
#wget -nc https://artifacts.unidata.ucar.edu/repository/downloads-udunits/udunits-2.2.28.tar.gz
#tar -xf udunits-2.2.28.tar.gz
#cd udunits-2.2.28
#./configure --prefix=$BUILD_DIR
#make -j $NP && make install

cd $TMPDIR 

# Install SQLite 3.38.2
wget -nc https://www.sqlite.org/2022/sqlite-autoconf-3380200.tar.gz
tar -xf sqlite-autoconf-3380200.tar.gz
cd sqlite-autoconf-3380200
./configure --prefix=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR

# Install curl 7.82.0
wget -nc https://curl.se/download/curl-7.82.0.tar.gz
tar -xf curl-7.82.0.tar.gz
cd curl-7.82.0
./configure --prefix=$BUILD_DIR --without-ssl
make -j $NP && make install

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64:/usr/lib64
export CPATH=$CPATH:$BUILD_DIR/include
export PKG_CONFIG_PATH=$PKG_CONFIG_PATH:$BUILD_DIR/lib/pkgconfig:$BUILD_DIR/lib64/pkgconfig
export PROJ_LIB=$BUILD_DIR/share/proj

cd $TMPDIR

# Install GEOS 3.10.2
wget -nc http://download.osgeo.org/geos/geos-3.10.2.tar.bz2
tar -xf geos-3.10.2.tar.bz2
cd geos-3.10.2
./configure --prefix=$BUILD_DIR
make -j $NP && make install

cd $TMPDIR

# Install PROJ 9.0.0
wget -nc https://download.osgeo.org/proj/proj-9.0.0.tar.gz
wget -nc https://download.osgeo.org/proj/proj-data-1.9.tar.gz
tar -xf proj-9.0.0.tar.gz
tar -xf proj-data-1.9.tar.gz
cd proj-9.0.0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$BUILD_DIR -DEXE_SQLITE3=$BUILD_DIR/bin/sqlite3 -DSQLITE3_INCLUDE_DIR=$BUILD_DIR/include -DSQLITE3_LIBRARY=$BUILD_DIR/lib/libsqlite3.so
make -j $NP && make install

cd $TMPDIR

# Install GDAL 3.4.2
wget -nc https://github.com/OSGeo/gdal/releases/download/v3.4.2/gdal-3.4.2.tar.gz
tar -xf gdal-3.4.2.tar.gz
cd gdal-3.4.2
./configure --with-sqlite3=$BUILD_DIR/lib --with-pcre --with-hdf5=/gpfs/group/RISE/sw7/hdf5-gcc-9.3.1/HDF_Group/HDF5/1.12.1 --with-proj=$BUILD_DIR --with-geos=$BUILD_DIR/bin/geos-config \
	LDFLAGS="-L$BUILD_DIR/lib -L$BUILD_DIR/lib64" CPPFLAGS=-I$BUILD_DIR/include PKG_CONFIG=$BUILD_DIR/lib/pkgconfig --prefix=$BUILD_DIR
make -j $NP && make install


cd ~/scratch
rm -rf tmp_lib

# INSTALL R PACKAGES:
R --vanilla << EOF
install.packages("units", configure.args = "--with-udunits2-lib=$BUILD_DIR/lib64 --with-udunits2-include=$BUILD_DIR/udunits2 udunits2=$BUILD_DIR/include", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.1", repos="http://cran.us.r-project.org")
install.packages("sf", configure.args = "--with-gdal-config=$BUILD_DIR/bin/gdal-config --with-gdal-lib=$BUILD_DIR/lib --with-proj_api=$BUILD_DIR/include --with-proj-lib=$BUILD_DIR/lib64 --with-proj-include=$BUILD_DIR/include --with-proj-share=$BUILD_DIR/share/proj --with-geos-config=$BUILD_DIR/bin/geos-config", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.1", repos="http://cran.us.r-project.org")
install.packages("rgdal", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.1", repos="http://cran.us.r-project.org")
q()
EOF
# install.packages("rgdal", configure.args = "--with-gdal-config=$BUILD_DIR/bin/gdal-config --with-proj_api=$BUILD_DIR/include/proj_api.h --with-proj-lib=$BUILD_DIR/lib --with-proj-include=$BUILD_DIR/include --with-proj-share=$BUILD_DIR/share/proj LDFLAGS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' CPPFLAGS=-I$BUILD_DIR/include LIBS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' INCLUDE_DIR=-I$BUILD_DIR/include", lib = "$HOME/R/x86_64-redhat-linux-gnu-library/3.6/", repos="http://cran.us.r-project.org")
