#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ d0cee62 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/collection.sh
. ../.lib/assert.sh
shift 2
cd "$1" || exit; shift

test_vec() {
  local RESULT
  vec_
  assert_eq "$RESULT" ""
  vec_ bar foo baz "aaa${ch_lf}aaa"
  assert_eq -m 2de7562 "$RESULT" "bar${ch_us}foo${ch_us}baz${ch_us}aaa${ch_lf}aaa${ch_us}"
  vsort_ "$RESULT"
  assert_eq -m a10ae3a "$RESULT" "aaa${ch_lf}aaa${ch_us}bar${ch_us}baz${ch_us}foo${ch_us}"
  local s=  
  _() {
    s="$s$1"
  }; veach "$RESULT"
  assert_eq -m c327416 "$s" "aaa${ch_lf}aaabarbazfoo"
}
