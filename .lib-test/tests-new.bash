# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 375eadd && return 0

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/assert.sh
shift 2
cd "$1" || exit 1; shift

# pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
# . ./.lib/utils.bash
# popd >/dev/null || exit 1

test_new_success() {
  local foo="FOO"
  assert_eq "$foo" "FOO"
}

test_new_success2() {
  assert_eq "$((1 + 2 + 3 + 4))" 10
}

cleanup1bash() { echo cleanup1bash; };
cleanup2bash() { echo cleanup2bash; };
cleanup3bash() { echo cleanup3bash; };

test_prepend_cleanup_bash() {
  local temp_file
  temp_file="$(mktemp)"
  prepend_cleanup cleanup1bash
  (
    prepend_cleanup cleanup2bash
    prepend_cleanup cleanup3bash
  ) >"$temp_file"
  grep -q cleanup1bash "$temp_file" && false
  grep -q cleanup2bash "$temp_file" || false
  grep -q cleanup3bash "$temp_file" || false
  rm -f "$temp_file"
}
