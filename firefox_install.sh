#!/bin/bash
# Script to install Firefox 52.8.0
# Written by Ghanghoon "Will" Paik (gip5038@psu.edu)
# Feb 19 2019

echo "This script will install Firefox 52.8.0 in ~/work/firefox"

wget http://mirror.centos.org/centos/6/os/x86_64/Packages/firefox-52.8.0-1.el6.centos.x86_64.rpm
rpm2cpio firefox-52.8.0-1.el6.centos.x86_64.rpm | cpio -idmv

if [[ ! -d "${HOME}/work/firefox" ]] ; then
	mv ./usr ~/work/firefox
else
	echo "directory already exist"
	rsync -rvh ./usr/* ~/work/firefox/
fi

rm -rf firefox-52.8.0-1.el6.centos.x86_64.rpm
rm -rf etc

cd $HOME/work/firefox/bin
rm firefox
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/work/firefox/lib64/
	$HOME/work/firefox/lib64/firefox/firefox" >> firefox
chmod +x firefox

