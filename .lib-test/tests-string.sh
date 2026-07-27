#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 8ec10fe && return 0

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
. ../.lib/string.sh
. ../.lib/misc.sh
cd "$3" || exit; shift 3

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
  local RESULT
  gsub_ "foo bar baz bar 123" "bar" "xyz"
  assert_eq "$RESULT" "foo xyz baz xyz 123"
  gsub_ "foo" "" "bar"
  assert_eq "$RESULT" "foo"
}

test_string_index() {
  index_ "peanut" "an"
  assert_eq -m df40914 "$RESULT" 3
  index_ "peanut" "XXX"
  assert_eq -m cfed5a9 "$RESULT" 0
  index_ "" ""
  assert_eq -m 8f518b3 "$RESULT" 0
  index_ "foo" ""
  assert_eq -m 741fa10 "$RESULT" 0
}

test_string_length() {
  length_ "apple"
  assert_eq "$RESULT" 5
}

test_string_split() {
  split_ "cul-de-sac" "-"
  assert_eq "$RESULT" "cul de sac"

  split_ --result-delimiter="${CH_US}" "foo bar baz|hoge fuga |hare" "|"
  assert_eq "$RESULT" "foo bar baz${CH_US}hoge fuga ${CH_US}hare"
  local saved_ifs="$IFS"; local IFS="$CH_US"
  local arg
  for arg in $RESULT
  do
    echo c80fd85 "$arg"
  done
  IFS="$saved_ifs"
}

test_cmdbase_snake() {
  cmdbase_snake_ "/home/foo/bin/some"
  assert_eq "some" "$RESULT"
  cmdbase_snake_ "/home/foo/bin/some_name"
  assert_eq "some_name" "$RESULT"
  cmdbase_snake_ "/home/foo/bin/some-name"
  assert_eq "some_name" "$RESULT"
  cmdbase_snake_ "/home/foo/bin/some-name.sh"
  assert_eq "some_name" "$RESULT"
}
