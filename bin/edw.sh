#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_EDW_SH && return # shpp:source_guard

# Launch editor and block until it exits.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:begin_source
. ./ed.sh
cd "$3" || exit; shift 3 # shpp:end_source

edw() {
  ed --wait "$@"
}

case "${0##*/}" in
  (edw.sh|edw)
    set -o nounset -o errexit
    edw "$@"
    ;;
esac
