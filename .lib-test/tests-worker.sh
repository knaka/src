#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 68518a9 && return

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/worker.sh
. ../.lib/assert.sh
. ../.lib/test.sh
cd "$3" || exit; shift 3

: "${path_3da3ab4-}"

fn_not_to_clean_901f64b() {
  echo marker7029f65
  sleep 4567 &
  echo "$!" >"$path_3da3ab4"
  wait
}

test_worker() {
  skip_if is_bbwin
  skip_if is_brush

  init_worker_queue
  run_rec_worker sleep 1234
  local wid="$WID"
  wait_worker_start --timeout-sec=10 "$wid"
  kill -0 "$(pid_of_worker "$wid")"
  run_worker sleep 2345
  local wid2="$WID"
  wait_worker_start --timeout-sec=10 "$wid" "$wid2"
  is_worker_alive "$wid" "$wid2"
  run_worker --group sleep 3456
  # Nothing to `wait`.
  wait
  stop_worker "$wid"
  wait_worker --timeout-sec=10 "$wid"
  assert_failure kill -0 "$(pid_of_worker "$wid")" >/dev/null 2>&1

  local pwd="$PWD"
  local wid_log=
  # shellcheck disable=SC2016
  run_log_worker --chdir=/ sh -c 'printf "eeba269 %s a9a1413" "$(pwd)"'
  wid_log="$WID"
  wait_worker_start --timeout-sec=10 "$wid_log"
  assert_eq -m 378d175 "$pwd" "$PWD"
  assert_eq "eeba269 / a9a1413" "$(log_worker "$wid_log")"

  if is_bash_bin && ! is_brush
  then
    path_3da3ab4="$TEMP_DIR/b39f0df"
    run_rec_worker --group fn_not_to_clean_901f64b
    local wid3="$WID"
    while ! test -r "$path_3da3ab4"
    do
      sleep 0.1
    done
    wait_worker_start "$wid3"
    log_worker "$wid3" | grep marker7029f65
    stop_worker --timeout-sec=10 "$wid3"
    assert_failure kill -0 "$(cat "$path_3da3ab4")"
  fi
}

_() { case "${0##*[/\\]}" in ("$1"|"$1".*) ;; (*) false;; esac; }; if _ tests-worker
then
  set -o nounset -o errexit
  test_worker "$@"
fi
