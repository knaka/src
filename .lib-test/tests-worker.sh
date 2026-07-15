#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 68518a9 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/worker.sh
. ../.lib/assert.sh
shift 2
set -- _LIBDIR . "$@"
. ./test.sh
shift 2
cd "$1" || exit; shift

skip_cond_ce1f35f() {
  (is_macos && ! is_bash_bin) || is_bbwin
}

test_worker() {
  skip_if skip_cond_ce1f35f

  init_worker_queue
  local wid
  wid="$(run_worker sleep 1234)"
  wait_worker_start --timeout-sec=10 "$wid"
  kill -0 "$(pid_of_worker "$wid")"
  wid2="$(run_worker sleep 2345)"
  wait_worker_start --timeout-sec=10 "$wid" "$wid2"
  is_worker_alive "$wid" "$wid2"
  run_worker sleep 3456 >/dev/null 2>&1
  wait
  stop_worker "$wid"
  wait_worker --timeout-sec=10 "$wid"
  assert_failure kill -0 "$(pid_of_worker "$wid")" >/dev/null 2>&1
}
