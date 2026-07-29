#!/usr/bin/env bash
set -- __MISE_TASKS_NEW_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# Bash foo.
#MISE hide=true
task_bash__foo() {
  if is_windows
  then
    echo This is a Windows. >&2
  else
    echo This is not a Windows. >&2
  fi
}

# Bash bar.
task-bash--bar() {
  echo ce12cf4 >&2
}

# Baz task.
#TASK
baz() {
  echo baz
}

# Not used desc.
#TASK name=bash:baz desc="Bash baz." dummy=foo
bash_baz() {
  echo baz
}
