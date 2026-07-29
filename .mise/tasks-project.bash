#!/usr/bin/env bash
set -- __MISE_TASKS_PROJECT_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/worker.sh
. ../.lib/build.sh
popd >/dev/null || exit

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
