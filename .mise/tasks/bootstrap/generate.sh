#!/usr/bin/env sh
set -- __MISE_TASKS_BOOTSTRAP_GENERATE_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

#MISE description="Generate Mise bootstrap scripts."

#EMBED: ./_mise
cat_sh_e52f026() { cat <<'EOF'
#!/usr/bin/env sh
set -- _83da9bf "$@"; eval "shift; \${$1-false} || ! $1=true" && return || :

# Mise - Home | mise-en-place https://mise.jdx.dev/
mise_ver_e8ccfbb=2026.7.5

should_exec_9bf84a8=false

mise() {
  local os
  local exe_ext=
  if test -d \\
  then
    os=windows
    exe_ext=.exe
  elif test -r /System/Library/CoreServices/SystemVersion.plist
  then
    os=macos
  elif test -d /proc -a -d /sys/kernel
  then
    os=linux
  else
    return 1
  fi
  local cache_dir_path="${XDG_CACHE_HOME-$HOME/.cache}"/mise
  local cmd_base="mise-$mise_ver_e8ccfbb$exe_ext"
  local cmd_path="$cache_dir_path/$cmd_base"
  if ! command -v "$cmd_path" >/dev/null 2>&1
  then
    mkdir -p "$cache_dir_path"
    cd "$cache_dir_path" || return 1
    local arch
    case "$(uname -m)" in
      (x86_64) arch=x64;;
      (arm64|aarch64) arch=arm64;;
      (*) return 1;;
    esac
    local exe_base="mise-v$mise_ver_e8ccfbb-$os-$arch$exe_ext"
    local exe_url="https://github.com/jdx/mise/releases/download/v$mise_ver_e8ccfbb/$exe_base"
    echo "Downloading $exe_url" >&2
    curl --fail --location "$exe_url" -o "$exe_base" || return 1
    local sum_url="https://github.com/jdx/mise/releases/download/v$mise_ver_e8ccfbb/SHASUMS256.txt"
    echo "Downloading $sum_url" >&2
    curl --fail --location "$sum_url" -o - | grep "/$exe_base$" | sha256sum -c - >&2
    mv -f "$exe_base" "$cmd_base"
    chmod +x "$cmd_path"
    cd "$OLDPWD" || exit 1
  fi
  "$should_exec_9bf84a8" && exec "$cmd_path" "$@"
  command "$cmd_path" "$@"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) :;; (*) ! :;; esac; }; if _ mise
then
  set -o nounset -o errexit
  should_exec_9bf84a8=true
  mise "$@"
fi
EOF
}

#EMBED: ./_mise.cmd
cat_cmd_7825e46() { cat <<'EOF'
@REM Home | mise-en-place https://mise.jdx.dev/
@REM Releases · jdx/mise https://github.com/jdx/mise/releases
@set ver=__MISE_VERSION__

@echo off
setlocal enabledelayedexpansion

if "%PROCESSOR_ARCHITECTURE%" == "AMD64" (
  set mise_arch=x64
) else if "%PROCESSOR_ARCHITECTURE%" == "ARM64" (
  set mise_arch=arm64
) else (
  echo ERROR: Unexpected architecture "%PROCESSOR_ARCHITECTURE%". >&2
  exit /b 1 
)

set cache_dir_path=%USERPROFILE%\.cache\mise
if not exist !cache_dir_path! (
  mkdir "!cache_dir_path!"
)
set cmd_path=!cache_dir_path!\mise-%ver%.exe
if not exist !cmd_path! (
  echo Downloading Mise for Windows. >&2
  curl.exe --fail --location --output "!cmd_path!" https://github.com/jdx/mise/releases/download/v!ver!/mise-v!ver!-windows-!mise_arch!.exe || exit /b !ERRORLEVEL!
)
!cmd_path! %* || exit /b !ERRORLEVEL!

endlocal ^
& "%cmd_path%" %* || exit /b %ERRORLEVEL%
EOF
}

generate() {
  cd "${MISE_ORIGINAL_CWD-.}" || exit 1
  local ver
  ver="$(mise version | cut -d' ' -f1)"
  cat_sh_e52f026 | sed -e "s/^mise_ver_e8ccfbb=.*$/mise_ver_e8ccfbb=$ver/" >mise
  chmod +x mise
  cat_cmd_7825e46 | sed -e "s/^@set ver=.*$/@set ver=$ver/" >mise.cmd
  cd "$OLDPWD" || exit 1
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (generate.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  generate "$@"
fi
