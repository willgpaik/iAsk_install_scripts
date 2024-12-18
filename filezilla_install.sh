#!/bin/bash
# Script to install Filezilla-3.7.3
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Oct 12 2018
# Last updated: Feb 19 2019


mkdir -p ~/work/filezilla_tmp
cd ~/work/filezilla_tmp
wget http://dl.fedoraproject.org/pub/epel/6/x86_64/Packages/f/filezilla-3.7.3-3.el6.x86_64.rpm
rpm2cpio filezilla-3.7.3-3.el6.x86_64.rpm | cpio -imd

if [[ ! -d "${HOME}/work/filezilla" ]] ; then
	mv ./usr ~/work/filezilla
else
	echo "directory already exist"
	rsync -rvh ./usr/* ~/work/filezilla/
fi

cd ~/work
rm -rf ~/work/filezilla_tmp

echo "alias filezilla='${HOME}/work/filezilla/bin/filezilla'" >> ~/.bashrc

