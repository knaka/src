#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_MISE_BOOTSTRAP_GENERATE_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.mise/tasks/bootstrap "$OLDPWD" "$@" # shpp:sources
. ../.mise/tasks/bootstrap/generate
cd "$3" || exit; shift 3 # /shpp:sources

mise_bootstrap_generate() {
  generate "$@"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (mise-bootstrap-generate.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  mise_bootstrap_generate "$@"
fi
