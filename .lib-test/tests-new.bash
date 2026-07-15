# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 375eadd && return 0

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
shift 2
. ./test.sh
cd "$1" || exit 1; shift

{ pushd "${BASH_SOURCE[0]%[/\\]*}" || pushd .; } >/dev/null 2>&1
set -- _LIBDIR ../.lib "$@"
. ../.lib/assert.sh
shift 2
popd >/dev/null || exit 1

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

test_cleanup_child_processes_bash() {
  init_temp
  local child_pid_file="$TEMP_DIR/child_pid"

  set -m
  (
    register_child_cleanup
    trap : TERM
    sleep 100 &
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

  assert_false -m 8147d97 kill -0 "$child_pid" 2>/dev/null
  assert_false -m 0e61473 kill -0 "$harness_pid" 2>/dev/null
}
