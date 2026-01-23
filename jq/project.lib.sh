# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_08b072b-false}" && return 0; sourced_08b072b=true

. ./task.sh
. ./dasel.lib.sh

subcmd_test() {
  echo "Running tests with shell ${SH}."
  subcmd_task__test "$@"
}
