#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 8ec10fe && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
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

  split_ --result-delimiter="${ch_us}" "foo bar baz|hoge fuga |hare" "|"
  assert_eq "$RESULT" "foo bar baz${ch_us}hoge fuga ${ch_us}hare"
  local saved_ifs="$IFS"; local IFS="$ch_us"
  local arg
  for arg in $RESULT
  do
    echo c80fd85 "$arg"
  done
  IFS="$saved_ifs"
}

test_result_name() {
  set_result_name "RESULT_X"
  local x="it's a \$test * [glob] \"quote\""
  set_result "$x"
  assert_eq "$x" "$RESULT_X"
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
