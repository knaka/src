#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ c6857eb && return

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

test_env() {
  if is_mise
  then
    echo Under Mise. >&2
  fi
  if is_bash_bin
  then
    bash --version
  elif is_bbwin
  then
    busybox --help
  elif test -r /proc/$$/exe
  then
    echo "/proc/$$/exe"
    readlink /proc/$$/exe | xargs basename
  elif is_macos
  then
    ps -p $$ -o args=
  else
    echo Invalid env. >&2
  fi
}
