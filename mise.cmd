@echo off
setlocal enabledelayedexpansion

@REM BusyBox for Windows https://frippery.org/busybox/index.html
@REM Release Notes https://frippery.org/busybox/release-notes/index.html
@REM Index of /files/busybox https://frippery.org/files/busybox/?C=M;O=D
set bb_ver=FRP-5857-g3681e397f

@REM Home | mise-en-place https://mise.jdx.dev/
@REM Releases · jdx/mise https://github.com/jdx/mise/releases
set mise_ver=2026.2.7

if "%PROCESSOR_ARCHITECTURE%" == "x86" (
  echo WARNING: Your environment is 32-bit. Not all features are supported. >&2
  set arch=32
) else if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set bb_arch=64u
) else if "%PROCESSOR_ARCHITECTURE%" == "ARM64" (
  set bb_arch=64a
) else (
  echo ERROR: Unexpected architecture "%PROCESSOR_ARCHITECTURE%". >&2
  exit /b 1 
)

set cmd_name=busybox.exe
set cache_dir_path=%USERPROFILE%\.cache\task-sh\busybox@%bb_ver%
if not exist !cache_dir_path! (
  mkdir "!cache_dir_path!"
)
set cmd_path=!cache_dir_path!\!cmd_name!
if not exist !cmd_path! (
  echo Downloading BusyBox for Windows. >&2
  curl.exe --fail --location --output "!cmd_path!" https://frippery.org/files/busybox/busybox-w!bb_arch!-!bb_ver!.exe || exit /b !ERRORLEVEL!
)
if not exist !cache_dir_path!\sh.exe (
  !cmd_path! --install !cache_dir_path!
)

@REM Prepend path
set PATH=!cache_dir_path!;%PATH%s

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set mise_arch=x64
) else if "%PROCESSOR_ARCHITECTURE%" == "ARM64" (
  set mise_arch=arm64
) else (
  echo ERROR: Unexpected architecture "%PROCESSOR_ARCHITECTURE%". >&2
  exit /b 1 
)

set cache_dir_path=%USERPROFILE%\.cache\task-sh\mise@%mise_ver%
if not exist !cache_dir_path! (
  mkdir "!cache_dir_path!"
)
set cmd_name=mise.exe
set cmd_path=!cache_dir_path!\!cmd_name!
if not exist !cmd_path! (
  echo Downloading Mise for Windows. >&2
  set zip_path=!cache_dir_path!\mise.zip
  curl.exe --fail --location --output "!zip_path!" https://github.com/jdx/mise/releases/download/v!mise_ver!/mise-v!mise_ver!-windows-!mise_arch!.zip || exit /b !ERRORLEVEL!
  unzip.exe "!zip_path!" -d !cache_dir_path!\work || exit /b !ERRORLEVEL!
  mv.exe -f !cache_dir_path!\work\mise\bin\mise.exe "!cache_dir_path!"
  rm.exe -f "!zip_path!"
  rm.exe -fr !cache_dir_path!\work
)
!cmd_path! %* || exit /b !ERRORLEVEL!

endlocal
