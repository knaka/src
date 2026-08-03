@echo off

cd %MISE_TOOL_INSTALL_PATH%\msys64

C:\Windows\System32\curl.exe -fsSL -o temp.tar.zst https://mirror.msys2.org/msys/x86_64/diffutils-3.12-1-x86_64.pkg.tar.zst
C:\Windows\System32\tar.exe --zstd -xf temp.tar.zst

del temp.tar.zst
