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
if "%PLATFORM%"=="x64" set GENERATOR="%GENERATOR% Win64"

rem configure build files
cmake -G %GENERATOR% -DCMAKE_BUILD_TYPE=%CONFIGURATION% -DKSP_MANAGED_PATH=%cd%/../KSP_runtime/KSP_Data/Managed ..
cd ..
