#!/bin/sh
PREFIX=$(readlink -f $1)
PREMAKE_VERSION=5.0.0.alpha4
PREMAKE_ARCH=linux
PREMAKE_VERSION_FULL=${PREMAKE_VERSION}-${PREMAKE_ARCH}
PREMAKE_URL=https://github.com/premake/premake-core/releases/download/v5.0.0.alpha4/premake-${PREMAKE_VERSION_FULL}.tar.gz
CMAKE_VERSION=3.3.1
CMAKE_ARCH=Linux-x86_64
CMAKE_VERSION_FULL=${CMAKE_VERSION}-${CMAKE_ARCH}
CMAKE_URL=http://www.cmake.org/files/v3.3/cmake-${CMAKE_VERSION_FULL}.tar.gz

echo "PREFIX: $PREFIX"

[ ! -d $PREFIX/tools/bin ] && mkdir -p $PREFIX/tools/bin

# Premake
# Update iff it does not exist or the version has changed.
if [ ! -x "$PREFIX/tools/bin/premake5" -o ! -f "$PREFIX/tools/premake.version" ] || grep -vq "$PREMAKE_VERSION" $PREFIX/tools/premake.version; then
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

$PREFIX/tools/bin/premake5 --version | tee $PREFIX/tools/premake.version
$PREFIX/tools/bin/cmake --version | head -n1 | tee $PREFIX/tools/cmake.version
