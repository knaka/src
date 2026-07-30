# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_RAND7_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# Generates a random 7-digit hexadecimal number
rand7() {
  local seed
  if test -r /dev/urandom
  then
    # Generate seed from /dev/urandom if available
    seed=$(od -An -N4 -tu4 </dev/urandom | tr -d ' ')
  elif is_macos
  then
    # Generate seed from current timestamp on macOS in second precision
    seed=$(date +%s)
  else
    # Generate seed from nanoseconds since epoch on other platforms
    seed=$(date +%N)
  fi
  # 0.0 <= rand() < 1.0
  # 268435456 = 0xFFFFFFF + 1
  # Hexadecimal integer literal is available only on GAwk.
  awk -v seed="$seed" 'BEGIN { srand(seed); printf "%07x\n", int(rand() * 268435456) }'
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (rand7.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  rand7 "$@"
fi
