#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_2387b8e-false}" && return 0; sourced_2387b8e=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR ./mise-tasks "$@"
. ./mise-tasks/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

case "${0##*/}" in
  (mise|mise.sh)
    set -o nounset -o errexit
    mise "$@"
    ;;
esac

# # Canonicalize `uname -s` result
# uname_s() {
#   local os_name; os_name="$(uname -s)"
#   case "$os_name" in
#     (Windows_NT|MINGW*|CYGWIN*) os_name="Windows" ;;
#   esac
#   echo "$os_name"
# }

# mise() {
#   # Releases · jdx/mise https://github.com/jdx/mise/releases
#   local ver="2026.2.7"

#   local dir="$HOME/.cache/task-sh/mise@$ver"
#   mkdir -p "$dir"
#   local cmd_path="$dir"/mise
#   if ! test -x "$cmd_path"
#   then
#     case "$(uname -s)" in
#       (Linux) os=linux;;
#       (Darwin) os=macos;;
#       (Windows_NT|MINGW*|CYGWIN*) os="windows" ;;
#       (*) echo e4454ba >&2; exit;;
#     esac
#     case "$(uname -m)" in
#       (x86_64) arch=x64;;
#       (arm64) arch=arm64;;
#       (*) echo 65aa9c9 >&2; exit;;
#     esac
#     if is_windows
#     then
#       # https://github.com/jdx/mise/releases/download/v2026.2.7/mise-v2026.2.7-windows-x64.zip
#       local url="https://github.com/jdx/mise/releases/download/v${ver}/mise-v${ver}-${os}-${arch}.zip"
#       curl --fail --location "$url" --output "$cmd_path"
#       chmod 755 "$cmd_path"
#     else
#       local url="https://github.com/jdx/mise/releases/download/v${ver}/mise-v${ver}-${os}-${arch}"
#       curl --fail --location "$url" --output "$cmd_path"
#       chmod 755 "$cmd_path"
#     fi
#   fi
#   exec "$cmd_path" "$@"
# }
