#!/usr/bin/env sh
set -- __LIB_TEST_TESTS_STRING_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/assert.sh
. ../.lib/string.sh
. ../.lib/misc.sh
cd "$3" || exit; shift 3 # /shpp:sources

test_string_case() {
  local result
  tolower -v result "AbC:XyZ:123"
  # shellcheck disable=SC2153
  assert_eq "$result" "abc:xyz:123"
  toupper -v result "AbC:XyZ:123"
  assert_eq "$result" "ABC:XYZ:123"
}

test_string_substr() {
  local result
  substr -v result "123456789" 4 3
  assert_eq "$result" "456"
  assert_eq "456789" "$(substr "123456789" 4)"
}

test_string_sub() {
  local result
  strsub -v result "foo bar baz bar" "bar" "xyz"
  assert_eq "$result" "foo xyz baz bar"
  assert_eq "foo" "$(strsub "foo" "" "bar")"
}

test_string_gsub() {
  local result
  strgsub -v result "foo bar baz bar 123" "bar" "xyz"
  assert_eq "$result" "foo xyz baz xyz 123"
  assert_eq "foo" "$(strgsub "foo" "" "bar")"
}

test_string_index() {
  local result
  strpos -v result "peanut" "an"
  assert_eq -m df40914 "$result" 3
  strpos -v result "peanut" "XXX"
  assert_eq -m cfed5a9 "$result" 0
  strpos -v result "" ""
  assert_eq -m 8f518b3 "$result" 0
  assert_eq -m 741fa10 0 "$(strpos "foo" "")"
}

test_string_length() {
  local result
  strlen -v result "apple"
  assert_eq 5 "$result"
  assert_eq 6 "$(strlen orange)"
}

test_string_split() {
  assert_eq "cul de sac" "$(strsplit "cul-de-sac" "-")"

  local result
  strsplit -v result --result-delimiter="${CH_US}" "foo bar baz|hoge fuga |hare" "|"
  assert_eq "$result" "foo bar baz${CH_US}hoge fuga ${CH_US}hare"
  local saved_ifs="$IFS"; local IFS="$CH_US"
  local arg
  for arg in $result
  do
    echo c80fd85 "$arg"
  done
  IFS="$saved_ifs"
}

# shellcheck disable=SC2153
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
