#!/usr/bin/env bash
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 7fac086 && return

pushd "${BASH_SOURCE[0]%[/\\]*}" >/dev/null 2>&1 || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/worker.sh
. ../.lib/build.sh
popd || exit >/dev/null

task_sub__gen() {
  _() {
    echo Build for changed files: "$@"
    touch ./README.md
  }
  depbuild "$@" ./README.md "./.source/**/*.txt" "./.source2/**/*.txt" -- _
}

task_gen() {
  trap_terminating_signals
  local wids=
  init_worker_queue

  run_worker task_sub__gen "$@"
  wids="$wids $WID"

  # shellcheck disable=SC2086
  wait_worker $wids
}
