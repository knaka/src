#!/usr/bin/env bash
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 2ce0894 && return 0

{ pushd "${BASH_SOURCE[0]%/*}" || pushd "${BASH_SOURCE[0]%\\*}" || pushd .; } >/dev/null 2>&1
set -- _LIBDIR ../.lib "$@"
shift 2
. ../.lib/worker.bash
popd >/dev/null || exit 1

test_worker() {
  init_worker_queue
  local wid
  wid="$(run_worker sleep 1234)"
  wait_worker_start --timeout-sec=10 "$wid"
  kill -0 "$(pid_of_worker "$wid")"
  wid2="$(run_worker sleep 2345)"
  wait_worker_start --timeout-sec=10 "$wid" "$wid2"
  is_worker_alive "$wid" "$wid2"
  stop_worker "$wid"
  wait_worker --timeout-sec=10 "$wid"
  ! kill -0 "$(pid_of_worker "$wid")" >/dev/null 2>&1
}

test_zzz() {
  init_temp 
  ls -l "$TEMP_DIR"
}
