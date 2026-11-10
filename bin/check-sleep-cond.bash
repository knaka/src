#!/usr/bin/env bash
set -- _fa1817d "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ./sleep-utils-macos.bash
. ../.lib/time.sh
popd >/dev/null || exit

say_and_log() {
  say "$@"
  echo "$(date_iso): $*" >>"$logfile"
}

check_sleep_cond() {
  while :
  do
    # if is_lid_closed
    # then
    #   ja_say "蓋は閉まっています。"
    # else
    #   ja_say "蓋は開いています。"
    # fi

    if is_dark_wake
    then
      say_and_log "Dark wake."
    else
      say_and_log "Full wake."
    fi

    sleep 1
  done
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 check_sleep_cond "$@"
fi
