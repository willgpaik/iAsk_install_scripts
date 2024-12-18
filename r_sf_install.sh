#!/bin/bash
# Script to install SQLite 3.35.5, curl 7.64.1, udunits2 2.2.20, gdal 3.2.2, geos 3.9.1, proj 7.2.1
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Oct 19 2020
# Last updated: Aug 22 2021

# Taken from r_spdep_dependency_install_user.sh
# Installs dependencies on work directory (~500 MB)
# Packages for R 4.1
# Updated for RHEL 7

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

module use /gpfs/group/RISE/sw7/modules
module load automake
module load r
module load gcc
module load hdf5

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

mv ./usr ~/work/sf_dep
BUILD_DIR=~/work/sf_dep

cd $TMPDIR 

# Install SQLite latest
wget -nc https://www.sqlite.org/2021/sqlite-autoconf-3350500.tar.gz
tar -xf sqlite-autoconf-3350500.tar.gz
cd sqlite-autoconf-3350500
./configure --prefix=$BUILD_DIR
make -j $NP
make install

cd $TMPDIR

# Install curl 7.64.1
wget -nc https://curl.haxx.se/download/curl-7.69.1.tar.gz
tar -xf curl-7.69.1.tar.gz
cd curl-7.69.1
./configure --prefix=$BUILD_DIR
make -j $NP && make install

export PATH=$BUILD_DIR/bin:$PATH
export LD_LIBRARY_PATH=$BUILD_DIR/lib:$BUILD_DIR/lib64:/usr/lib64:$LD_LIBRARY_PATH
export CPATH=$CPATH:$BUILD_DIR/include
export PKG_CONFIG_PATH=$BUILD_DIR/lib/pkgconfig:$BUILD_DIR/lib64/pkgconfig:$PKG_CONFIG_PATH
export PROJ_LIB=$BUILD_DIR/share/proj

cd $TMPDIR

# Install GEOS 3.9.1
wget -nc http://download.osgeo.org/geos/geos-3.9.1.tar.bz2
tar -xf geos-3.9.1.tar.bz2
cd geos-3.9.1
./configure --prefix=$BUILD_DIR
make -j $NP
make install

cd $TMPDIR

# Install PROJ 7.2.1
wget -nc https://download.osgeo.org/proj/proj-7.2.1.tar.gz
wget -nc https://download.osgeo.org/proj/proj-data-1.5.tar.gz
tar -xf proj-7.2.1.tar.gz
tar -xf proj-data-1.5.tar.gz
cd proj-7.2.1
./configure --prefix=$BUILD_DIR
make -j $NP
make install

cd $TMPDIR

# Install GDAL 3.2.2
wget -nc https://github.com/OSGeo/gdal/releases/download/v3.2.2/gdal-3.2.2.tar.gz
tar -xf gdal-3.2.2.tar.gz
cd gdal-3.2.2
./configure --with-sqlite3=$BUILD_DIR/lib --with-pcre --with-hdf5=/opt/aci/sw/hdf5/1.10.7_gcc-8.3.1-5uj --with-proj=$BUILD_DIR --with-geos=$BUILD_DIR/bin \
	LDFLAGS="-L$BUILD_DIR/lib -L$BUILD_DIR/lib64" CPPFLAGS=-I$BUILD_DIR/include PKG_CONFIG=$BUILD_DIR/lib/pkgconfig --prefix=$BUILD_DIR
make -j $NP
make install


cd ~/scratch
rm -rf tmp_lib

# INSTALL R PACKAGES:
R --vanilla << EOF
install.packages("units", configure.args = "--with-udunits2-lib=$BUILD_DIR/lib64 --with-udunits2-include=$BUILD_DIR/udunits2 udunits2=$BUILD_DIR/include", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.1/", repos="http://cran.us.r-project.org")
install.packages("sf", configure.args = "--with-gdal-config=$BUILD_DIR/bin/gdal-config --with-gdal-lib=$BUILD_DIR/lib --with-proj_api=$BUILD_DIR/include --with-proj-lib=$BUILD_DIR/lib --with-proj-include=$BUILD_DIR/include --with-proj-share=$BUILD_DIR/share/proj --with-geos-config=$BUILD_DIR/bin/geos-config", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.1/", repos="http://cran.us.r-project.org")
install.packages("rgdal", configure.args = "--with-gdal-config=$BUILD_DIR/bin/gdal-config --with-proj-lib=$BUILD_DIR/lib64 --with-proj-include=$BUILD_DIR/include --with-proj-share=$BUILD_DIR/share/proj LDFLAGS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' CPPFLAGS=-I$BUILD_DIR/include LIBS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' INCLUDE_DIR=-I$BUILD_DIR/include", lib = "$HOME/R/x86_64-pc-linux-gnu-library/4.1/", repos="http://cran.us.r-project.org")
q()
EOF
