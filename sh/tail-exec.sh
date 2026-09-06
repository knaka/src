#!/usr/bin/env sh
set -- _8768813 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

foo() {
  tail_exec /bin/echo Hello
}

x_349b6f3() {
  foo # Does not exec(2).
  FORCE_EXEC=true foo # Does exec(2).
  echo Not reached. >&2
  exit 1
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (tail-exec.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  x_349b6f3 "$@"
fi
