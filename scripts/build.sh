#!/bin/sh
set -e
# see .travis.yml for the env variables.

if [ -z "$KERON_CC" ]; then 
  echo "BAD Travis-CI env (see https://github.com/travis-ci/travis-ci/issues/4681) - SKIP"
  exit 0
fi

rm -rf build
mkdir build && cd build

# For now, the client is skipped on analyze phases.
if [ ! "$KERON_ANALYZE" ]; then
  CC="$KERON_CC" CXX="$KERON_CXX" cmake -G Ninja \
	-DCMAKE_BUILD_TYPE=$BUILD_TYPE \
	-DKSP_MANAGED_PATH=$PWD/../KSP_runtime/KSP_Data/Managed \
	-DCPACK_GENERATOR=TGZ ..
  ninja -v client
else
  ${KERON_ANALYZE} cmake -G Ninja -DCMAKE_BUILD_TYPE=$BUILD_TYPE -DKSP_MANAGED_PATH=$PWD/../KSP_runtime/KSP_Data/Managed ..
fi

${KERON_ANALYZE} ninja -v keron

cd ..
