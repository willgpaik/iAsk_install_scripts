BootStrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum
%setup

%files

%environment 

%runscript


%post
    # commands to be executed inside container during bootstrap
    # add python and install some packages
    yum install -y epel-release
    yum install -y terminator
    yum install -y centos-release-scl
    yum install -y vte-devel
    yum install -y vte291-devel
    yum install -y vte-profile
    yum install -y centos-release-scl
#    yum -y install devtoolset-7
    yum install -y devtoolset-7-gcc*
    scl enable devtoolset-7 bash
    yum -y groups install "Development Tools"
#    yum -y groups install "GNOME Desktop"
    yum -y groups install "Base"
#    yum -y groups install "X Window System" "Desktop" "Fonts"
    yum -y install git cmake gcc-c++ gcc binutils \
        libX11-devel libXpm-devel libXft-devel libXext-devel
    yum -y install gcc-gfortran openssl-devel pcre-devel \
        mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel \
        fftw-devel cfitsio-devel graphviz-devel \
        avahi-compat-libdns_sd-devel libldap-dev python-devel \
        libxml2-devel gsl-devel
    yum -y install openmpi-devel
    yum -y install cmake3
    yum -y install hdf5-devel
#    yum -y install boost-devel
    yum -y install patch
    yum -y update

    mkdir -p /storage/home
    mkdir -p /storage/work/sw/src
    mkdir -p /gpfs/scratch
    mkdir -p /gpfs/group

    echo "scl enable devtoolset-7 bash" >> ~/.bashrc

    # Install Boost
    cd /storage/work/sw
    wget https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz
    tar -xf boost_1_69_0.tar.gz
    cd boost_1_69_0
    ./bootstrap.sh
    ./b2

    # Install root
    cd /storage/work/sw/
#    wget https://root.cern.ch/download/root_v6.14.04.Linux-centos7-x86_64-gcc4.8.tar.gz
#    tar -xf root_v6.14.04.Linux-centos7-x86_64-gcc4.8.tar.gz
#    rm root_v6.14.04.Linux-centos7-x86_64-gcc4.8.tar.gz
    wget https://root.cern/download/root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
    tar -xf root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
    . root/bin/thisroot.sh
    echo ". /storage/work/sw/root/bin/thisroot.sh" >> ~/.bashrc

    # Install locust_mc
    cd /storage/work/sw
    git clone "https://github.com/project8/locust_mc"
    cd locust_mc
    git submodule update --init --recursive
    git clone https://github.com/project8/Kassiopeia.git
    cd ..
    sed -i -e 's/option( locust_mc_BUILD_WITH_KASSIOPEIA "Option to build with Kassiopeia" FALSE )/option( locust_mc_BUILD_WITH_KASSIOPEIA "Option to build with Kassiopeia" TRUE )/' CMakeLists.txt
    mkdir build
    cd build
    cmake3 ..
    make install
    . bin/source/kasperenv.sh
    echo ". /storage/work/sw/locust_mc/build/bin/kasperenv.sh" >> ~/.bashrc


    # Delete tar files
    cd /storage/work/sw/
    rm root_v6.16.00.Linux-centos7-x86_64-gcc4.8.tar.gz
    rm boost_1_69_0.tar.gz




