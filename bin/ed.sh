#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_ED_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
appdir_5d34c62="$PWD"
cd "$3" || exit; shift 3 # /shpp:sources

ed() {
  cd "$appdir_5d34c62" || return 1
  mise exec -- python ./_chdir.py "$OLDPWD" "$appdir_5d34c62"/ed.py "$@"
  cd "$OLDPWD" || return 1
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.ed.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  ed "$@"
fi
