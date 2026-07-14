# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_70ed462-false}" && return 0; sourced_70ed462=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
shift 2
cd "$1" || exit 1; shift

test_unconditional_skip() {
  skip
}

func_global_ifs() {
  IFS="$ch_lf"
  assert_eq "$ch_lf" "$IFS"
  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 3
}

func_local_ifs() {
  local IFS="$ch_lf"
  assert_eq "$ch_lf" "$IFS"
  # shellcheck disable=SC2046
  set -- $(printf "foo bar\nbar baz\nhoge fuga\n")
  assert_eq $# 3
}

# Test that IFS with local works and does not affects outer scope one.
test_local_ifs() (
  original_ifs="$IFS"
  
  func_global_ifs
  # IFS should still be changed after function returns
  assert_eq "$ch_lf" "$IFS"
  
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

  local IFS="$ch_lf"

  # shellcheck disable=SC2046
  set -- $(printf "x%s\n" "$@")
  assert_eq 2 $#
  assert_eq "xaaa  bbb" "$1"
  assert_eq "xccc" "$2"

  # shellcheck disable=SC2046
  set -- $(printf '%s' '["foo   bar", "baz"]' | jq -r '.[]')
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

# If you need job control, prefer writing it in Bash rather than sh (which could be ash or dash).
test_cleanup_child_processes() {
  # Dash does assign a new PGID when job control is enabled, but `kill -TERM 0` appears to terminate the parent as well.
  skip_unless is_bash_bin

  init_temp
  local child_pid_file="$TEMP_DIR/child_pid"

  set -m
  (
    register_child_cleanup
    sleep 100 &
    echo "$!" >"$child_pid_file"
    wait
    echo This must not be printed. >&2
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

  assert_false -m 3e0485f kill -0 "$child_pid" 2>/dev/null
  assert_false -m 4a65d72 kill -0 "$harness_pid" 2>/dev/null
}
