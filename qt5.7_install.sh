#!/bin/bash
# Script to install Qt 5.7 (Base and SVG)
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Jan 25 2020
# Note: it takes long time to build
# NOT TESTED YET

module load gcc

if [[ ! -z "$PBS_NODEFILE" ]]; then
	NP=$(wc -l $PBS_NODEFILE | awk '{print $1}')
else
	NP=1;
fi
echo "Number of threads used for installation: $NP"

BASE=$PWD
mkdir -p $BASE/qt5.7
mkdir -p $BASE/QT_TMP

BUILD_DIR=$BASE/qt5.7
TMPDIR=$BASE/QT_TMP

 # Install QtBase
cd $TMPDIR
git clone https://github.com/qt/qtbase.git
cd qtbase
git checkout 5.7
./configure -opensource -confirm-license -silent -nomake examples -sysroot /opt/rh/devtoolset-7/root/usr/bin -prefix $BUILD_DIR
# https://www.qtcentre.org/threads/16301-Qt-installation-error
#find $TMPDIR/qtbase/src -iname '*.pl' -print0 | xargs -0 chmod -c -x
gmake -j $NP
gmake install

export PATH=$BUILD_DIR/bin:$PATH
export LD_LIBRARY_PATH=$BUILD_DIR:$LD_LIBRARY_PATH

#find $BUILD_DIR/bin -iname '*.pl' -print0 | xargs -0 chmod -c -x


# Install QtSVG
cd $TMPDIR
git clone https://github.com/qt/qtsvg.git
cd qtsvg
git checkout 5.7
qmake-qt5 PREFIX=$BUILD_DIR
make -j $NP && make install


cd /tmp
rm -rf qtbase qtsvg
