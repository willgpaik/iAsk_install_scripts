BootStrap: yum
OSVersion: 7
MirrorURL: http://mirror.centos.org/centos-%{OSVERSION}/%{OSVERSION}/os/$basearch/
Include: yum
%setup

%files

%environment
    export PATH LD_LIBRARY_PATH CPATH CUDA_HOME
    LD_PRELOAD="/opt/eod/lib/libopentextdlfaker.so.3:/opt/eod/lib/libopentextglfaker.so.3 \
        :/opt/eod/lib64/libopentextdlfaker.so.3:/opt/eod/lib64/libopentextglfaker.so.3"
    export LD_PRELOAD

%apprun python
  exec python "${@}"

%apprun conda
  exec conda "${@}"

%runscript
  exec "${@}"


%post
    # commands to be executed inside container during bootstrap
    # add python and install some packages
    yum update -y
    yum install -y epel-release
    yum install -y terminator
    yum install -y centos-release-scl
    yum install -y vte-devel
    yum install -y vte291-devel
    yum install -y vte-profile
    yum install -y devtoolset-7-gcc*
    scl enable devtoolset-7 bash
    yum -y groups install "Development Tools"
    yum -y groups install "Base"
    yum -y install git cmake gcc-c++ gcc binutils \
	libX11-devel libXpm-devel libXft-devel libXext-devel
    yum -y install gcc-gfortran openssl-devel pcre-devel \
	mesa-libGL-devel mesa-libGLU-devel glew-devel ftgl-devel mysql-devel \
	fftw-devel cfitsio-devel graphviz-devel \
	avahi-compat-libdns_sd-devel libldap-dev python-devel python36-devel \
	libxml2-devel gsl-devel
    yum -y install openmpi-devel
    yum -y install cmake3
    yum -y install hdf5-devel
#    yum -y install boost-devel
    yum -y install patch
    yum -y install qt5-qtbase-devel
    yum -y install qt5-qtsvg-devel
    yum -y install git g++ numpy eigen3-devel zlib-devel libqt4-devel libgl1-mesa-dev libtiff-devel
    yum -y install bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion
    yum -y update
   
    mkdir -p /storage/home
    mkdir -p /storage/work
    mkdir -p /gpfs/scratch
    mkdir -p /gpfs/group

    mkdir -p /opt/sw/
    cd /opt/sw/
    wget https://repo.anaconda.com/archive/Anaconda3-2018.12-Linux-x86_64.sh
    bash Anaconda3-2018.12-Linux-x86_64.sh -b -p /opt/sw/anaconda3

    conda create -n deformetrica && source activate deformetrica

    conda install -c pytorch -c conda-forge -c anaconda -c aramislab deformetrica

    
    # Download requires libraries for EoD:
    cd /opt/
    svn export https://github.com/willgpaik/MorphoGraphX_aci.git/trunk/eod_graphics_libraries
    mv eod_graphics_libraries eod


    cd /opt/sw/
    rm Anaconda3-2018.12-Linux-x86_64.sh


