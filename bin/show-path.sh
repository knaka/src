#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_SHOW_PATH_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

show_path() {
  # if is_windows
  # then
  #   echo 'Not for Windows. Call "win-env" instead.' >&2
  #   exit 1
  # fi
  local IFS=':'
  # shellcheck disable=SC2086
  printf "%s\n" $PATH
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.show-path.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  show_path "$@"
fi
