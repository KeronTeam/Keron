cinst -y curl
curl -sSL --insecure -o ksp-runtime.7z %archive_url%
7z x -p%archive_pwd% ksp-runtime.7z
