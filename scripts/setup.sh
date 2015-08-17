#!/bin/sh
PREFIX=$1
PREMAKE_VERSION=5.0.0.alpha4
PREMAKE_ARCH=linux
PREMAKE_VERSION_FULL=${PREMAKE_VERSION}-${PREMAKE_ARCH}
PREMAKE_URL=https://github.com/premake/premake-core/releases/download/v5.0.0.alpha4/premake-${PREMAKE_VERSION_FULL}.tar.gz
CMAKE_VERSION=3.3.1
CMAKE_ARCH=Linux-x86_64
CMAKE_VERSION_FULL=${CMAKE_VERSION}-${CMAKE_ARCH}
CMAKE_URL=http://www.cmake.org/files/v3.3/cmake-${CMAKE_VERSION_FULL}.tar.gz

[ ! -d $PREFIX/tools ] && mkdir -p $PREFIX/tools/bin

# Premake
# Update iff it does not exist or the version has changed.
PREMAKE_CORRECT_VERSION=$($PREFIX/tools/bin/premake5 --version | grep -om1 "$PREMAKE_VERSION")
if [ ! -x "$PREFIX/tools/bin/premake5" -o ! "$PREMAKE_CORRECT_VERSION" ]; then
  echo "UPDATING premake"
  wget -O /tmp/premake-dev-linux.tar.gz $PREMAKE_URL
  ls -l /tmp/premake-dev-linux.tar.gz
  file /tmp/premake-dev-linux.tar.gz
  tar -C $PREFIX/tools/bin -xzf /tmp/premake-dev-linux.tar.gz
else
  echo "*NOT* UPDATING premake"
fi

# CMake
# Same as above.
CMAKE_CORRECT_VERSION=$($PREFIX/tools/bin/cmake --version | grep -om1 "$CMAKE_VERSION")
if [ ! -x "$PREFIX/tools/bin/cmake" -o ! "$CMAKE_CORRECT_VERSION" ]; then
  echo "UPDATING cmake"
  wget -O /tmp/cmake-linux.tar.gz $CMAKE_URL
  ls -l /tmp/cmake-linux.tar.gz
  file /tmp/cmake-linux.tar.gz
  tar -C $PREFIX/tools -xzf /tmp/cmake-linux.tar.gz
CMAKE_DIR=`readlink -f $PREFIX/tools/cmake-$CMAKE_VERSION_FULL`
  ln -fs $CMAKE_DIR/bin/* $PREFIX/tools/bin
else
  echo "*NOT* UPDATING cmake"
fi

ls -l $PREFIX/tools/bin

# KSP runtime archive.
wget --no-check-certificate -q -O /tmp/ksp-runtime-linux.7z $ARCHIVE_URL
7z -h
7z x -p$ARCHIVE_PWD /tmp/ksp-runtime-linux.7z

$PREFIX/tools/bin/premake5 --version
$PREFIX/tools/bin/cmake --version
