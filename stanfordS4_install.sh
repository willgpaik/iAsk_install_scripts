# Script to install Stanford S4 with Lua 5.3.5
# Written by Will Paik (gip5038@psu.edu)
# Feb 01 2019

BASE=$PWD

# Load required modules:
module load python/3.6.3-anaconda5.0.1
module load gcc/5.3.1
module load openmpi
module load fftw
module load blas
module load lapack

if [[ -f activateS4 ]] ; then
        rm activateS4
fi

# Install Lua 5.3.5 (required to install S4)
wget -nc https://www.lua.org/ftp/lua-5.3.5.tar.gz
tar -xf lua-5.3.5.tar.gz
cd lua-5.3.5
make linux test

cd src
echo "export LD_LIBRARY_PATH=$PWD:$LD_LIBRARY_PATH" >> $BASE/activateS4
echo "export CPATH=$PWD:$CPATH" >> $BASE/activateS4
echo "export PATH=$PWD:$PATH" >> $BASE/activateS4

cd $BASE
chmod +x activateS4
./activateS4

if [[ "lua -v | grep -q '5.3.5'" ]] ; then
        echo "Lua 5.3.5 is successfully installed!"
else
        echo "ERROR: Failed to install Lua 5.3.5"
        exit 1
fi

# Install Stanford S4
cd $BASE
git clone https://github.com/victorliu/S4.git
cd S4

sed -i -e 's|LA_LIBS.*|LA_LIBS = -L/opt/aci/sw/lapack/3.6.0_gcc-5.3.1/usr/lib64/ -L/opt/aci/sw/blas/3.6.0_gcc-5.3.1/usr/lib64/ -llapack -lblas|g' Makefile.Linux
sed -i -e 's|LUA_INC.*|LUA_INC = -I'"${BASE}"'/lua-5.3.5/src|g' Makefile.Linux
sed -i -e 's|LUA_LIB.*|LUA_LIB = -L'"${BASE}"'/lua-5.3.5/src/ -llua|g' Makefile.Linux
sed -i -e 's|MPI_INC.*|MPI_INC = /opt/aci/sw/openmpi/1.10.1_gcc-5.3.1/bin|g' Makefile.Linux
sed -i -e 's|MPI_LIB.*|MPI_INC = /opt/aci/sw/openmpi/1.10.1_gcc-5.3.1/lib|g' Makefile.Linux
sed -i -e '/CFLAGS/s/$/ -Wl,--no-as-needed -ldl/' Makefile.Linux
sed -i -e '/CXXFLAGS/s/$/ -Wl,--no-as-needed -ldl/' Makefile.Linux

make

export PATH=$PATH:$BASE/S4/build
echo "export PATH=$PATH:$BASE/S4/build" >> $BASE/activateS4
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BASE/S4/build" >> $BASE/activateS4

if [[ S4 ]] ; then
	echo "Stanford S4 is successfully installed!"
else
	echo "ERROR: Failed to install Stanford S4"
        exit 1
fi


