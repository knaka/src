#!/usr/bin/env sh
set -- _BIN_COWSAY_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

# cowsay - npm https://www.npmjs.com/package/cowsay
cowsay_version_14ac6ce=1.6.0

set_cowsay_version() {
  cowsay_version_14ac6ce="$1"
}

cowsay() {
  mise exec "npm:cowsay@$cowsay_version_14ac6ce" -- cowsay "$@"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (cowsay.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  cowsay "$@"
fi
