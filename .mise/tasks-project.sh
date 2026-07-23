# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_a32832b-false}" && return 0; sourced_a32832b=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/worker.sh
. ../.lib/build.sh
shift 2
cd "$1" || exit 1; shift 2


task_gen() {
  trap_terminating_signals
  local wids=
  init_worker_queue

  _() {
    echo Do something for: "$*"
    touch ./README.md
  }
  run_worker depbuild "$@" ./README.md ".source/*.txt" ".source2/*.txt"
  wids="$wids $WID"

  # shellcheck disable=SC2086
  wait_worker $wids
}
