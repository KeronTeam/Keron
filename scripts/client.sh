#!/bin/sh
KSP_DIR=$1
rm -rf build/*
premake5 --cc=gcc --arch=x64 --ksp=$1 gmake
sed -i '/\@echo.*\.cs >> \$(RESPONSE)$/ { s/\\/\//g; }' build/*.make
make -C build/ config=release verbose=1 client
