#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_BEEP_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # shpp:end_source

beep() {
  if is_windows
  then
    # pwsh -c "[console]::beep(1000,300)" &
    rundll32 user32.dll,MessageBeep &
  elif is_macos
  then
    osascript -e 'beep' &
  else
    # Emit a terminal bell (BEL) character to trigger an audible or visual alert.
    printf '\a'
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.beep.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  beep "$@"
fi
