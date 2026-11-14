#!/usr/bin/env sh
set -- _1685ad5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# Percent-encode the arguments joined with spaces, or the standard input if none, byte by byte, leaving only the unreserved characters of RFC 3986 as they are. Every byte, including newlines and those of multibyte characters, is encoded regardless of the locale, since od converts the input to hex codes before awk reads it. No newline is written at the end.
urlencode() {
  # od(1)
  #   -An: no address
  #   -v: write out all input
  #   -tx1: format, hexadecimal, each 1 byte
  if test $# -gt 0
  then
    printf "%s" "$*"
  else
    cat
  fi \
  | od -An -v -tx1 \
  | awk '
BEGIN {
  # Map the hex codes of the unreserved characters to themselves.
  for (i = 32; i < 127; i++) {
    c = sprintf("%c", i)
    if (c ~ /^[0-9A-Za-z._~-]$/) {
      keep[sprintf("%02x", i)] = c
    }
  }
}

{
  for (i = 1; i <= NF; i++) {
    printf "%s", ($i in keep) ? keep[$i] : "%" toupper($i)
  }
}
'
}

# Decode the percent-encoded arguments, or the standard input if none, and write out the bytes as they are. Raw newlines are regarded as the terminators of encoded lines, such as the one urlencode writes, and are discarded, so that `urlencode | urldecode` gives back the original bytes. A NUL byte (%00) cannot be decoded, since awk cannot handle it.
urldecode() {
  if test $# -gt 0
  then
    printf "%s" "$*"
  else
    cat
  fi \
  | LANG=C LC_ALL=C awk '
BEGIN {
  for (i = 0; i < 256; i++) {
    byte[sprintf("%02X", i)] = i
  }
}

{
  s = $0
  while (match(s, /%[0-9A-Fa-f][0-9A-Fa-f]/)) {
    printf "%s%c", substr(s, 1, RSTART - 1), byte[toupper(substr(s, RSTART + 1, 2))]
    s = substr(s, RSTART + 3)
  }
  printf "%s", s
}
'
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (urlencode.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  urlencode "$@"
fi
