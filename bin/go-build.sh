#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_GO_BUILD_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

go_build() {
  # If the directory from which a command is executed is in a symlink and it appears outside of the workspace the IDE is working in, the debugger treats breakpoints as not set.
  push_dir "$(realpath "$PWD")"
  set -- build -gcflags='all=-N -l' "$@"
  echo Executing: go "$@" 2>&1
  go "$@"
  pop_dir
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.go-build.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  go_build "$@"
fi
