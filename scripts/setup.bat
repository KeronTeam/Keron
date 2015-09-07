rem see appveyor.yml for the env vars.
rem fetch sub repos.
git submodule init
git submodule update

rem prepare build directory
del /F /S build
mkdir build
cd build

rem select generator.
set GENERATOR="Visual Studio %VS_VERSION%"
if "%PLATFORM%"=="x64" set GENERATOR="Visual Studio %VS_VERSION% Win64"
set CLIENT_ONLY=""

rem the server only works for x64
if "%PLATFORM%"=="Win32" set CLIENT_ONLY="-DKERON_BUILD_SERVER=OFF"

rem configure build files
cmake -G %GENERATOR% -DCMAKE_BUILD_TYPE=%CONFIGURATION% %CLIENT_ONLY% -DKSP_MANAGED_PATH=%cd%/../KSP_runtime/KSP_Data/Managed ..
cd ..
