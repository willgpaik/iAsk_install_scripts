#!/bin/bash
# Script to install postgres R postgres
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jul 1 2023

module purge
module use /storage/icds/RISE/sw8/modules/
module load r/4.3.0

if [[ ! -d "~/R/x86_64-pc-linux-gnu-library/4.3" ]]; then
	mkdir -p ~/R/x86_64-pc-linux-gnu-library/4.3
fi

if [[ ! -z "$SLURM_NPROCS" ]]; then
	NP=$SLURM_NPROCS;
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p postgres_tmp

BUILD_DIR=$PWD/postgres
TMPDIR=$PWD/postgres_tmp

cd $TMPDIR
# Install postgres
wget -nc https://dl.fedoraproject.org/pub/epel/8/Modular/x86_64/Packages/p/postgresql-11.15-2.module_el8+13988+76873a69.x86_64.rpm
wget -nc https://dl.fedoraproject.org/pub/epel/8/Modular/x86_64/Packages/p/postgresql-devel-11.15-2.module_el8+13988+76873a69.x86_64.rpm
wget -nc https://dl.fedoraproject.org/pub/epel/8/Modular/x86_64/Packages/p/postgresql-libs-11.15-2.module_el8+13988+76873a69.x86_64.rpm
rpm2cpio postgresql-11.15-2.module_el8+13988+76873a69.x86_64.rpm | cpio -idm
rpm2cpio postgresql-devel-11.15-2.module_el8+13988+76873a69.x86_64.rpm | cpio -idm
rpm2cpio postgresql-libs-11.15-2.module_el8+13988+76873a69.x86_64.rpm | cpio -idm

mv usr $BUILD_DIR

export PATH=$PATH:$BUILD_DIR/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64
export CPATH=$CPATH:$BUILD_DIR/include

R --vanilla << EOF
install.packages("RPostgres", repos="http://cran.us.r-project.org", dependencies = TRUE, lib="$HOME/R/x86_64-pc-linux-gnu-library/4.3")
install.packages("RJDBC", repos="http://cran.us.r-project.org", dependencies = TRUE, lib="$HOME/R/x86_64-pc-linux-gnu-library/4.3")
EOF


# Add to bashrc
if [[ -f $BUILD_DIR/bin/pg_config ]]; then
	echo "postgres is successfully installed!"
	module purge
	echo "# ##### postgres >>>>>" >> ~/.bashrc
	echo "export PATH=$PATH:$BUILD_DIR/bin" >> ~/.bashrc
	echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/lib:$BUILD_DIR/lib64" >> ~/.bashrc
	echo "export CPATH=$CPATH:$BUILD_DIR/include" >> ~/.bashrc
	echo "# <<<<< postgres #####" >> ~/.bashrc
	echo "Please type: source ~/.bashrc"
else
	echo "postgres installation failed!"
fi


cd $BASE

rm -rf $TMPDIR
