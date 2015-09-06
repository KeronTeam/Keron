#!/bin/sh
PREFIX=$(readlink -f $1)
CMAKE_VERSION=3.3.1
CMAKE_ARCH=Linux-x86_64
CMAKE_VERSION_FULL=${CMAKE_VERSION}-${CMAKE_ARCH}
CMAKE_URL=http://www.cmake.org/files/v3.3/cmake-${CMAKE_VERSION_FULL}.tar.gz

echo "PREFIX: $PREFIX"

[ ! -d $PREFIX/tools/bin ] && mkdir -p $PREFIX/tools/bin

# CMake
# Same as above.
if [ ! -x "$PREFIX/tools/bin/cmake" -o ! -f "$PREFIX/tools/cmake.version" ] || grep -vq "$CMAKE_VERSION" $PREFIX/tools/cmake.version; then
  echo "UPDATING cmake"
  wget -O /tmp/cmake-linux.tar.gz $CMAKE_URL
  ls -l /tmp/cmake-linux.tar.gz
  file /tmp/cmake-linux.tar.gz
  tar -C $PREFIX/tools -xzf /tmp/cmake-linux.tar.gz
  ln -fs $PREFIX/tools/cmake-$CMAKE_VERSION_FULL/bin/* $PREFIX/tools/bin
else
  echo "*NOT* UPDATING cmake"
fi

ls -l $PREFIX/tools/bin

# KSP runtime archive.
wget --no-check-certificate -q -O /tmp/ksp-runtime-linux.7z $ARCHIVE_URL
7z -h
7z x -p$ARCHIVE_PWD /tmp/ksp-runtime-linux.7z

$PREFIX/tools/bin/cmake --version | head -n1 | tee $PREFIX/tools/cmake.version
