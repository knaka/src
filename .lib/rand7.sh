#!/usr/bin/env sh
set -- __LIB_RAND7_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

result_96fd1f7=

rand7_3c3619b() {
  if test -r /dev/urandom
  then
    local hex
    # The command substitution of a single simple command runs od(1) without forking a subshell.
    hex="$(od -An -N4 -tx4 </dev/urandom)"
    # Strip what od(1) prints before the number, which is spaces of a varying width. BSD od(1) prints trailing spaces and an extra newline as well.
    hex="${hex#"${hex%%[0-9a-f]*}"}"
    # Take the first 7 of the 8 hex digits, which od(1) pads with zeros.
    result_96fd1f7="${hex%"${hex#???????}"}"
    return 0
  fi
  # Generate seed from nanoseconds since epoch on other platforms
  local seed
  seed=$(date +%N)
  # 0.0 <= rand() < 1.0
  # 268435456 = 0xFFFFFFF + 1
  # Hexadecimal integer literal is available only on GAwk.
  result_96fd1f7="$(awk -v seed="$seed" 'BEGIN { srand(seed); printf "%07x\n", int(rand() * 268435456) }')"
}

# Print a random 7-digit hexadecimal number, or assign it to the variable given with "-v var".
# Usage: rand7 [-v var]
rand7() {
  local var_name_cd81b77=
  test "${1-}" = "-v" && var_name_cd81b77="$2" && shift 2
  rand7_3c3619b "$@" || return $?
  print_to "$var_name_cd81b77" "$result_96fd1f7"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (rand7.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  rand7 "$@"
fi
