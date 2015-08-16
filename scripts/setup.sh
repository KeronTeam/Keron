#!/bin/sh
PREMAKE_VERSION=5.0-alpha4-linux
PREMAKE_URL=http://garr.dl.sourceforge.net/project/premake/5.0/premake-${PREMAKE_VERSION}.tar.gz
CMAKE_VERSION=3.3.1-Linux-x86_64
CMAKE_URL=http://www.cmake.org/files/v3.3/cmake-${CMAKE_VERSION}.tar.gz

[ ! -d tools ] && mkdir -p tools/bin

# Premake
wget -O /tmp/premake-dev-linux.tar.gz $PREMAKE_URL
ls -l /tmp/premake-dev-linux.tar.gz
file /tmp/premake-dev-linux.tar.gz
tar -C tools/bin -xzf /tmp/premake-dev-linux.tar.gz

# CMake
wget -O /tmp/cmake-linux.tar.gz $CMAKE_URL
ls -l /tmp/cmake-linux.tar.gz
file /tmp/cmake-linux.tar.gz
tar -C tools -xzf /tmp/cmake.tar.gz
ln -s $PWD/cmake-$CMAKE_VERSION/bin/* $PWD/tools/bin

# KSP runtime archive.
wget --no-check-certificate -q -O /tmp/ksp-runtime-linux.7z $ARCHIVE_URL
- 7z -h
- 7z x -p$ARCHIVE_PWD /tmp/ksp-runtime-linux.7z
