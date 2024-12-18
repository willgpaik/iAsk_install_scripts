# This script installs R-3.4.3 with all dependencies
# Installation directory can be changed
# After the installation, executable command "R" will be
# added to $HOME/.bashrc as "r34"
# You may change name of the alias after installation

# Tested with module GCC/7.3.1

sed -i '/alias r34/d' $HOME/.bashrc

module load gcc

BASE=$PWD
mkdir -p $BASE/R_build
mkdir -p $BASE/tmp
RBUILD=$BASE/R_build

cd tmp

wget http://springdale.math.ias.edu/data/puias/computational/6/SRPMS/R-3.4.3-1.sdl6.src.rpm

rpm2cpio R-3.4.3-1.sdl6.src.rpm | cpio -idmv

echo Start extracting dependencies

if [[ ! -d "./build" ]]; then
    tar -xf bzip2-1.0.6.tar.gz
    tar -xf curl-7.56.1.tar.bz2
    tar -xf pcre-8.41.tar.bz2
    tar -xf R-3.4.3.tar.gz
    tar -xf xz-5.2.3.tar.bz2
    tar -xf zlib-1.2.11.tar.gz
fi

echo Finish extracting

mkdir build

cd bzip2-1.0.6
./configure --prefix=$RBUILD
make install PREFIX=$RBUILD
cd ..

cd curl-7.56.1
./configure --prefix=$RBUILD --without-libssh2
make && make install
cd ..

cd pcre-8.41
./configure --prefix=$RBUILD --enable-utf8 --enable-unicode-properties
make && make install
cd ..

cd xz-5.2.3
./configure --prefix=$RBUILD
make && make install
cd ..

cd zlib-1.2.11
./configure --prefix=$RBUILD
make && make install
cd ..

export CPATH=$CPATH:$RBUILD/include
export CPATH=$CPATH:$RBUILD/include/curl
export CPATH=$CPATH:$RBUILD/include/lzma
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$RBUILD/lib

cd $BASE/tmp
cd R-3.4.3
./configure PKG_CONFIG_PATH="$RBUILD/lib/pkgconfig" CPPFLAGS="-I/$RBUILD/include -I/$RBUILD/include/curl -I/$RBUILD/include/lzma" LDFLAGS="-L/$RBUILD/lib" --prefix=${RBUILD}
make && make install

echo "alias r34='$RBUILD/bin/R'" >> $HOME/.bashrc

source ~/.bashrc

if [[ -x $RBUILD/bin/R ]]; then
        r34 --version
        echo R-3.4.3 is successfully installed!
        echo You can use r34 to run it!
else
        echo Could not successfully install R-3.4.3
fi

cd $BASE
rm -rf tmp

