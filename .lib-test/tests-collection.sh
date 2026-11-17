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
  local v
  vec -v v
  assert_eq "$v" ""
  vempty "$v"
  vec -v v bar foo baz "aaa${CH_LF}aaa"
  assert_eq -m 2de7562 "$v" "bar${CH_US}foo${CH_US}baz${CH_US}aaa${CH_LF}aaa${CH_US}"
  vsort -v v "$v"
  assert_eq -m a10ae3a "$v" "aaa${CH_LF}aaa${CH_US}bar${CH_US}baz${CH_US}foo${CH_US}"
  local s=
  _() {
    s="$s$1"
  }; veach "$v" _
  assert_eq -m c327416 "$s" "aaa${CH_LF}aaabarbazfoo"
  # Without "-v", the result is printed.
  assert_eq -m 5e0d0b1 "a${CH_US}b${CH_US}" "$(vec a b)"
}

test_map() {
  local m
  map -v m k1 v1 k2 v2
  assert_eq -m 9c41a2e "$m" "k1${CH_US}v1${CH_US}k2${CH_US}v2${CH_US}"
  local value
  mget -v value "$m" k2
  assert_eq -m 3f7b8d4 "$value" v2
  assert_false mget "$m" none
  # Putting a value for an existing key replaces it and moves the entry to the end.
  mput -v m "$m" k1 V1
  assert_eq -m 6a2c9e7 "$m" "k2${CH_US}v2${CH_US}k1${CH_US}V1${CH_US}"
  local keys
  mkeys -v keys "$m"
  assert_eq -m b18d5f0 "$keys" "k2${CH_US}k1${CH_US}"
  mkeys -v keys ""
  assert_eq -m 0e9a3c6 "$keys" ""
  # The separator can be changed.
  m=
  mput -v m -s "#" "$m" key "value with spaces"
  mput -v m -s "#" "$m" bar BAR
  assert_eq -m 72d4b1a "$m" "key#value with spaces#bar#BAR#"
  assert_eq -m e5c8f29 "value with spaces" "$(mget -s "#" "$m" key)"
  assert_eq -m 4d1f6b3 "key#bar#" "$(mkeys -s "#" "$m")"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ tests-collection
then
  set -o nounset -o errexit
  "$@"
fi
