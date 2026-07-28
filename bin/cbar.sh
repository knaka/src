#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_CBAR_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:begin_source
. ./sc.sh
. ./gc.sh
cd "$3" || exit; shift 3 # shpp:end_source

# ClipBoard ARchiver
cbar() {
  if test $# -gt 0
  then
    # If arguments are specified, archive them as files/directories, convert to text, and set to clipboard.
    tar czvf - "$@" | base64 | sc
  else
    # If no arguments are specified, extract the clipboard content as an archive.
    gc | base64 -d | tar zxvf -
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.cbar.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  cbar "$@"
fi
