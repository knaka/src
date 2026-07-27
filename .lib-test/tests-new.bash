# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 375eadd && return 0

pushd "${BASH_SOURCE[0]%[/\\]*}" >/dev/null 2>&1 || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/assert.sh
. ../.lib/test.sh
popd || exit >/dev/null

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

test_register_exit_handler_bash() {
  local temp_file
  temp_file="$(mktemp)"
  add_exit_handler cleanup1bash
  (
    add_exit_handler cleanup2bash
    add_exit_handler cleanup2bash
    add_exit_handler cleanup3bash
  ) >"$temp_file"
  assert_failure grep -q cleanup1bash "$temp_file"
  assert_success grep -q cleanup2bash "$temp_file"
  assert_success grep -q cleanup3bash "$temp_file"
  rm -f "$temp_file"
}

test_cleanup_child_processes_bash() {
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
    assert_true -m d2557a0 test $i -lt 100
    sleep 0.1
  done
  local child_pid
  child_pid="$(cat "$child_pid_file")"

  kill -TERM "$harness_pid"
  sleep 0.5

  assert_false -m 8147d97 kill -0 "$child_pid"
  assert_false -m 0e61473 kill -0 "$harness_pid"
}

test_rc_variables() {
  local rc_sig_names
  rc_sig_names="$(compgen -A variable RC_SIG)"
  local rc_sig_name
  for rc_sig_name in $rc_sig_names
  do
    local rc_sig_value=
    eval "rc_sig_value=\"\$$rc_sig_name\""
    local sig_name="${rc_sig_name#RC_}"
    local sig_num
    sig_num="$(kill -l "$sig_name")"
    assert_eq -m fccf24f "$rc_sig_value" $((128 + sig_num))
    echo OK: "$rc_sig_name"
  done
}
