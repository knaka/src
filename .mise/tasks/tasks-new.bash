# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_b1cc8f6-false}" && return 0; sourced_b1cc8f6=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
popd >/dev/null || exit 1

# Bash foo.
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
