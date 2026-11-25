#!/usr/bin/env bash
set -- _LEAN__MISE_TASKS_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# Set up elan without modifying PATH or installing a default toolchain.
task_setup() {
  elan-init --verbose -y --no-modify-path --default-toolchain none
}

# ./lakefile.toml

# Build the default targets and print the paths of their outputs.
task_build() {
  lake build
  lake query
}

# Build and run the "foo" executable.
task_run() {
  local target=foo
  lake exe "$target"
}
