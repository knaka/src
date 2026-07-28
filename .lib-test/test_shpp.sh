#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ f3726c9 && return

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
scriptdir_6a245de="$PWD"
cd "$3" || exit; shift 3

test_shpp() {
  init_temp_dir

  local in_original="$scriptdir_6a245de"/testdata/shpp-in.sh
  local in="$TEMP_DIR"/dff5a61.sh
  local out_expected="$scriptdir_6a245de"/testdata/shpp-out.sh
  local out="$TEMP_DIR"/b606d65

  "$scriptdir_6a245de"/../.lib/shpp.pl "$in_original" >"$out"
  cmp -s "$out_expected" "$out"

  cp -af "$in_original" "$in"
  "$scriptdir_6a245de"/../.lib/shpp.pl --in-place "$in"
  cmp -s "$out_expected" "$out"
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ test_shpp
then
  set -o nounset -o errexit
  test_shpp "$@"
fi
