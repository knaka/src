# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_1e5cbd0-false}" && return 0; sourced_1e5cbd0=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR .lib "$@"
. .lib/task.sh
shift 2
cd "$1" || exit 1; shift

# [files...] Cat files with line num.
task_bar__baz() {
  # cat -n "$@"
  env
}

# [files...] Cat files with line num num.
task_bar__qux() {
  cat -n "$@" | cat -n
}
