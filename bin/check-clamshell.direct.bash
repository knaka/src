#!/usr/bin/env bash
set -- _2f9d6d5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

check_clamshell_state() {
  local voice="Samantha"
  export PATH="/usr/sbin:$PATH"
  if ioreg -r -k AppleClamshellState -d 1 | grep -qE '"AppleClamshellState" = Yes'
  then
    say -v "$voice" "Not sleeping even though the lid is closed."
  else
    # say -v "$voice" "The lid is open."
    :
  fi
  :
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 check_clamshell_state "$@"
fi
