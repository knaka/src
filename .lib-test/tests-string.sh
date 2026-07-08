#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 8ec10fe && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/assert.sh
. ./.lib/string.sh
shift 2
cd "$1" || exit 1; shift

test_string_case() {
  tolower_ "AbC:XyZ:123"
  # shellcheck disable=SC2153
  assert_eq "$RESULT" "abc:xyz:123"
  toupper_ "AbC:XyZ:123"
  assert_eq "$RESULT" "ABC:XYZ:123"
}

test_string_substr() {
  substr_ "123456789" 4 3
  assert_eq "$RESULT" "456"
  substr_ "123456789" 4
  assert_eq "$RESULT" "456789"
}

test_string_sub() {
  sub_ "foo bar baz bar" "bar" "xyz"
  assert_eq "$RESULT" "foo xyz baz bar"
  sub_ "foo" "" "bar"
  assert_eq "$RESULT" "foo"
}

test_string_gsub() {
  set_result_name RESULT_XYZ
  gsub_ "foo bar baz bar 123" "bar" "xyz"
  assert_eq "$RESULT_XYZ" "foo xyz baz xyz 123"
  gsub_ "foo" "" "bar"
  assert_eq "$RESULT_XYZ" "foo"
}

test_string_index() {
  index "peanut" "an"
  assert_eq "$RESULT" 3
  index "peanut" "XXX"
  assert_eq "$RESULT" 0
  index "" ""
  assert_eq "$RESULT" 0
  index "foo" ""
  assert_eq "$RESULT" 0
}

test_string_length() {
  length "apple"
  assert_eq "$RESULT" 5
}

test_string_split() {
  split "cul-de-sac" "-"
  assert_eq "$RESULT" "cul de sac"
}

test_result_name() {
  set_result_name "RESULT_X"
  local x="it's a \$test * [glob] \"quote\""
  set_result "$x"
  assert_eq "$x" "$RESULT_X"
}
