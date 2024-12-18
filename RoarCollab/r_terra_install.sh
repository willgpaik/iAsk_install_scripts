#!/bin/bash
# Script to install udunits2 2.2.26
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jan. 25 2024
# Updated: May 17 2024

module purge
module load python
module load hdf5
module load netcdf
module load cmake
module load r/4.3.2
module load gsl
module load gdal
module load geos
module load proj
module load tiff
module load udunits

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


cd $BASE

rm -rf $TMPDIR

R --vanilla << EOF
install.packages("units", configure.args = "--with-udunits2-lib=/storage/icds/RISE/sw8/udunits-2.2.28/lib --with-udunits2-include=/storage/icds/RISE/sw8/udunits-2.2.28/include udunits2=/storage/icds/RISE/sw8/udunits-2.2.28/include", lib = "~/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")

install.packages("sf", configure.args = "--with-sqlite3-lib=/storage/icds/RISE/sw8/sqlite-3.41.2/lib --with-gdal-config=/storage/icds/RISE/sw8/gdal-3.6.4/bin/gdal-config --with-gdal-lib=/storage/icds/RISE/sw8/gdal-3.6.4/lib64/libgdal.so --with-proj-lib=/storage/icds/RISE/sw8/proj-9.2.0/lib64 --with-proj-include=/storage/icds/RISE/sw8/proj-9.2.0/include --with-proj-share=/storage/icds/RISE/sw8/proj-9.2.0/share/proj --with-geos-config=/storage/icds/RISE/sw8/geos-3.11.2/bin/geos-config LDFLAGS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' CPPFLAGS=-I$BUILD_DIR/include", lib = "~/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")

install.packages("terra", configure.args = "--with-sqlite3-lib=/storage/icds/RISE/sw8/sqlite-3.41.2/lib --with-gdal-config=/storage/icds/RISE/sw8/gdal-3.6.4/bin/gdal-config --with-proj-lib=/storage/icds/RISE/sw8/proj-9.2.0/lib64/ --with-proj-include=/storage/icds/RISE/sw8/proj-9.2.0/include --with-proj-share=/storage/icds/RISE/sw8/proj-9.2.0/share/proj --with-geos-config=/storage/icds/RISE/sw8/geos-3.11.2/bin/geos-config LDFLAGS='-L$BUILD_DIR/lib -L$BUILD_DIR/lib64' CPPFLAGS=-I$BUILD_DIR/include", lib = "~/R/x86_64-pc-linux-gnu-library/4.3", repos="http://cran.us.r-project.org")

q()
EOF


# Add to bashrc
#echo "rgdal is successfully installed!"
#module purge
#echo "# ##### rgdal >>>>>" >> ~/.bashrc
#echo "export PATH=$PATH" >> ~/.bashrc
#echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> ~/.bashrc
#echo "export CPATH=$CPATH" >> ~/.bashrc
#echo "export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH" >> ~/.bashrc
#echo "export PKG_CONFIG_PATH=$PKG_CONFIG_PATH" >> ~/.bashrc
#echo "export PROJ_LIB=$PROJ_LIB" >> ~/.bashrc
#echo "# <<<<< rgdal #####" >> ~/.bashrc
#echo "Please type: source ~/.bashrc"
