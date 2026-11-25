#!/usr/bin/env bash
set -- _C__MISE_TASKS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# Build.
task_build() {
  mkdir -p ./.build
  cc -framework CoreGraphics -o ./.build/display-awake"$EXE_EXT" ./display-awake.c
}
