#!/bin/bash
# Script to install gdal 2.1.0, geos 3.6.2, proj 4.8.0 with nad and epsg
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# July 19 2019
# NOTE: Submit it as a job is recommended (takes long time to build)

## USE SPACK:
module load gcc/5.3.1
module load r
git clone https://github.com/spack/spack.git
. spack/share/spack/setup-env.sh
spack install gdal
spack install geos
spack install curl

spack load gdal
spack load geos
spack load proj
spacl load curl

wget https://github.com/manlius/muxViz/archive/master.zip
unzip master.zip
cd muxViz-master
R
> .libPaths("~/R/x86_64-redhat-linux-gnu-library/3.5")
> install.packages("sp")
> install.packages("rgdal")
> source('muxVizGUI.R')






devtools::install_github("trestletech/ShinyDash", lib="~/R/x86_64-redhat-linux-gnu-library/3.5")
devtools::install_github("rstudio/shiny-incubator", lib="~/R/x86_64-redhat-linux-gnu-library/3.5")
devtools::install_github("rstudio/d3heatmap", lib="~/R/x86_64-redhat-linux-gnu-library/3.5")




if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi

cd ~/scratch
mkdir tmp_lib
cd tmp_lib
TMPDIR=~/scratch/tmp_lib

module load gcc/5.3.1

# Install GDAL
wget https://github.com/OSGeo/gdal/archive/v2.1.0.tar.gz
tar -xf v2.1.0.tar.gz
cd gdal-2.1.0/gdal
./configure --prefix=$TMPDIR/usr
make -j $NP && make install

cd $TMPDIR

# Install GEOS
wget http://download.osgeo.org/geos/geos-3.6.2.tar.bz2
tar -xf geos-3.6.2.tar.bz2
cd geos-3.6.2
./configure --prefix=$TMPDIR/usr
make -j $NP && make install

cd $TMPDIR

wget http://elgis.argeo.org/repos/6/elgis/x86_64//proj-4.8.0-3.el6.x86_64.rpm
wget http://elgis.argeo.org/repos/6/elgis/x86_64//proj-devel-4.8.0-3.el6.x86_64.rpm
wget http://elgis.argeo.org/repos/6/elgis/x86_64//proj-epsg-4.8.0-3.el6.x86_64.rpm
wget http://elgis.argeo.org/repos/6/elgis/x86_64//proj-nad-4.8.0-3.el6.x86_64.rpm

rpm2cpio proj-4.8.0-3.el6.x86_64.rpm | cpio -idmv
rpm2cpio proj-devel-4.8.0-3.el6.x86_64.rpm | cpio -idmv
rpm2cpio proj-epsg-4.8.0-3.el6.x86_64.rpm | cpio -idmv
rpm2cpio proj-nad-4.8.0-3.el6.x86_64.rpm | cpio -idmv

cd $TMPDIR

mv usr ~/muxviz_dep

echo "export PATH=$PATH:$HOME/muxviz_dep/bin" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/muxviz_dep/lib:$HOME/muxviz_dep/lib64:/usr/lib64" >> ~/.bashrc
echo "export CPATH=$CPATH:$HOME/muxviz_dep/include" >> ~/.bashrc
