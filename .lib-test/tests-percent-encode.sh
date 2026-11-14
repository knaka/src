#!/usr/bin/env sh
set -- _e4a6fc1 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/percent-encode.sh
. ../.lib/assert.sh
cd "$3" || exit; shift 3 # /shpp:sources

test_percent_encode() {
  local original="hello world & Café"
  local encoded
  encoded="$(printf "%s" "$original" | percent_encode)"
  assert_eq -m "89491cd" "$encoded" "hello%20world%20%26%20Caf%C3%A9"
  local decoded
  decoded="$(printf "%s" "$encoded" | percent_decode)"
  assert_eq -m "627183a" "$original" "$decoded"
}
