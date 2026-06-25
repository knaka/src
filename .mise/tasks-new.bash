# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 43d0de4 && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
popd >/dev/null || exit 1

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

# baz task.
#TASK
baz() {
  echo baz
}

# bash:baz task.
#TASK name=bash:baz
bash_baz() {
  echo baz
}
