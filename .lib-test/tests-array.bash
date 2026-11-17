#!/usr/bin/env bash
set -- __LIB_TEST_TESTS_ARRAY_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/array.bash
. ../.lib/assert.sh
popd >/dev/null || exit

test_bash_array_mkeys() {
  # shellcheck disable=SC2034
  local m=(k1 v1 k2 v2 k3 v3)

  local keys1
  array_assign_stdin keys1 < <(array_mkeys m)
  assert_eq 3 "${#keys1[@]}"
  assert_eq "k1 k2 k3" "${keys1[*]}"

  local keys2=()
  array_mkeys -v keys2 m
  assert_eq 3 "${#keys2[@]}"
  assert_eq "k1 k2 k3" "${keys2[*]}"

  # Keys with spaces are kept, and the current elements are replaced.
  # shellcheck disable=SC2034
  local m3=("k \" 1" v1 "k 2" v2 "" v3 "k${CH_LF}4${CH_LF}" v4)
  local keys3=(x y z)
  array_mkeys -v keys3 m3
  assert_eq 4 "${#keys3[@]}"
  assert_eq "k \" 1" "${keys3[0]}"
  assert_eq "k 2" "${keys3[1]}"
  assert_eq "" "${keys3[2]}"
  assert_eq "k${CH_LF}4${CH_LF}" "${keys3[3]}"

  # An empty array gives no keys, even with nounset.
  # shellcheck disable=SC2034
  local m4=()
  local keys4=(x)
  array_mkeys -v keys4 m4
  assert_eq 0 "${#keys4[@]}"
}

test_bash_array_map() {
  local m=()
  array_mput -v m m k1 v1
  array_mput -v m m "k 2" "v 2"
  assert_eq 4 "${#m[@]}"

  local value
  array_mget -v value m "k 2"
  assert_eq "v 2" "$value"
  assert_eq v1 "$(array_mget m k1)"

  # Putting a value for an existing key replaces the entry and moves it to the end.
  array_mput -v m m k1 V1
  assert_eq 4 "${#m[@]}"
  assert_eq "k 2" "${m[0]}"
  assert_eq k1 "${m[2]}"
  array_mget -v value m k1
  assert_eq V1 "$value"

  # Printing gives the elements one per line.
  local m2
  array_assign_stdin m2 < <(array_mput m k3 v3)
  assert_eq 6 "${#m2[@]}"
  assert_eq v3 "${m2[5]}"
  # The given array is not changed without "-v" pointing to it.
  assert_eq 4 "${#m[@]}"

  # A missing key fails, and leaves the variable as it is.
  value=unchanged
  assert_failure array_mget -v value m no_such_key
  assert_eq unchanged "$value"
}
