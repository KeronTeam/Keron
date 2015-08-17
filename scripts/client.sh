#!/bin/sh
premake5 --cc=gcc --arch=x64 --ksp=$PWD/KSP_runtime gmake
sed -i '/\@echo.*\.cs >> \$(RESPONSE)$/ { s/\\/\//g; }' build/*.make
make -j2 -C build/ verbose=1
