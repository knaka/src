#!/usr/bin/env sh
set -- __LIB_SHPP_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
script_ccd23eb="$PWD"/shpp.pl
cd "$3" || exit; shift 3 # /shpp:sources

shpp() {
  perl "$script_ccd23eb" "$@"
}
