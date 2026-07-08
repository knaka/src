# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ c97d42e && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift

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

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ rand7
then
  set -o nounset -o errexit
  rand7 "$@"
fi
