cinst -y curl
cinst -v -f -y devbox-common.extension
cinst -v -f -y devbox-sed
url -sSL -o premake.zip https://github.com/premake/premake-core/releases/download/v5.0.0.alpha4/premake-5.0.0.alpha4-windows.zip
unzip premake.zip
