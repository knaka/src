#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ d0cee62 && return

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/collection.sh
. ../.lib/assert.sh
cd "$3" || exit; shift 3

test_vec() {
  local RESULT
  vec_
  assert_eq "$RESULT" ""
  vec_ bar foo baz "aaa${CH_LF}aaa"
  assert_eq -m 2de7562 "$RESULT" "bar${CH_US}foo${CH_US}baz${CH_US}aaa${CH_LF}aaa${CH_US}"
  vsort_ "$RESULT"
  assert_eq -m a10ae3a "$RESULT" "aaa${CH_LF}aaa${CH_US}bar${CH_US}baz${CH_US}foo${CH_US}"
  local s=  
  _() {
    s="$s$1"
  }; veach "$RESULT" _
  assert_eq -m c327416 "$s" "aaa${CH_LF}aaabarbazfoo"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ tests-collection
then
  set -o nounset -o errexit
  "$@"
fi
