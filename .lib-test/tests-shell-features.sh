# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_70ed462-false}" && return 0; sourced_70ed462=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
shift 2
. ./test.sh
cd "$1" || exit 1; shift

test_unconditional_skip() {
  skip
}

func_global_ifs() {
  IFS="$CH_LF"
  assert_eq "$CH_LF" "$IFS"
  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 3
}

func_local_ifs() {
  local IFS="$CH_LF"
  assert_eq "$CH_LF" "$IFS"
  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 3
}

# Test that IFS with local works and does not affects outer scope one.
test_local_ifs() (
  original_ifs="$IFS"
  
  func_global_ifs
  # IFS should still be changed after function returns
  assert_eq "$CH_LF" "$IFS"
  
  # Reset for next test
  IFS="$original_ifs"
  
  # Test that local IFS is restored after function returns
  
  func_local_ifs
  # IFS should be restored to original value
  assert_eq "$original_ifs" "$IFS"

  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 6
)

test_pos_params() {
  set -- "aaa  bbb" "ccc"
  assert_eq 2 $#

  local IFS="$CH_LF"

  # shellcheck disable=SC2046
  set -- $(printf "x%s\n" "$@")
  assert_eq 2 $#
  assert_eq "xaaa  bbb" "$1"
  assert_eq "xccc" "$2"

  # shellcheck disable=SC2046
  set -- $(printf '%s' '["foo   bar", "baz"]' | jq --binary -r '.[]')
  assert_eq -m "b0dafd8" 2 $#
  assert_eq "foo   bar" "$1"
  assert_eq "baz" "$2"

  local count
  # shellcheck disable=SC2046
  count="$(printf "%s\n" $(printf "x%s\n" "$@") | wc -l)"
  assert_eq -m "f52c6b3" 2 "$count"
}

test_trap_p() {
  skip_unless is_bash_bin
  # shellcheck disable=SC3045
  trap -p EXIT
}

job_control_available() {
  is_bash_bin || test -t 0
}

test_cleanup_child_processes() {
  skip_unless job_control_available

  init_temp_dir
  local child_pid_file="$TEMP_DIR/child_pid"

  set -m
  (
    register_child_cleanup
    sleep 1234 &
    echo "$!" >"$child_pid_file"
    wait || :
    echo Done. >&2
  ) &
  local harness_pid="$!"
  set +m
  sleep 0.1

  # Poll until child_pid_file appears.
  local i=0
  while ! test -s "$child_pid_file"
  do
    i=$((i + 1))
    assert_true -m 01da160 test $i -lt 100
    sleep 0.1
  done
  local child_pid
  child_pid="$(cat "$child_pid_file")"

  kill -TERM "$harness_pid"
  sleep 0.5

  assert_false -m 3e0485f kill -0 "$child_pid"
  assert_false -m 4a65d72 kill -0 "$harness_pid"
}

# shellcheck disable=SC2046
test_extglob() {
  local IFS
  IFS="$CH_LF"; set -- $(extglob "./foo bar/**/*.txt" "./bar baz/**/[h]*" | sort); unset IFS
  assert_eq -m=39edbb5 "$1" "./bar baz/hello world.c"
  assert_eq -m=ccbe8e7 "$2" "./bar baz/hello world.txt"
  assert_eq -m=e390cdd "$3" "./foo bar/hello world.txt"
  assert_eq -m=b98ff71 "$4" "./foo bar/hoge/hello.txt"
}
