#!/usr/bin/env sh
set -- _1685ad5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# Percent-encode the arguments joined with spaces, or the standard input if none, byte by byte, leaving only the unreserved characters of RFC 3986 as they are. Every byte, including newlines and those of multibyte characters, is encoded regardless of the locale, since od converts the input to hex codes before awk reads it. No newline is written at the end.
# [Percent-encoding - Wikipedia](https://en.wikipedia.org/wiki/Percent-encoding)
percent_encode() {
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
  keep["2d"] = "-"
  keep["2e"] = "."
  keep["30"] = "0"
  keep["31"] = "1"
  keep["32"] = "2"
  keep["33"] = "3"
  keep["34"] = "4"
  keep["35"] = "5"
  keep["36"] = "6"
  keep["37"] = "7"
  keep["38"] = "8"
  keep["39"] = "9"
  keep["41"] = "A"
  keep["42"] = "B"
  keep["43"] = "C"
  keep["44"] = "D"
  keep["45"] = "E"
  keep["46"] = "F"
  keep["47"] = "G"
  keep["48"] = "H"
  keep["49"] = "I"
  keep["4a"] = "J"
  keep["4b"] = "K"
  keep["4c"] = "L"
  keep["4d"] = "M"
  keep["4e"] = "N"
  keep["4f"] = "O"
  keep["50"] = "P"
  keep["51"] = "Q"
  keep["52"] = "R"
  keep["53"] = "S"
  keep["54"] = "T"
  keep["55"] = "U"
  keep["56"] = "V"
  keep["57"] = "W"
  keep["58"] = "X"
  keep["59"] = "Y"
  keep["5a"] = "Z"
  keep["5f"] = "_"
  keep["61"] = "a"
  keep["62"] = "b"
  keep["63"] = "c"
  keep["64"] = "d"
  keep["65"] = "e"
  keep["66"] = "f"
  keep["67"] = "g"
  keep["68"] = "h"
  keep["69"] = "i"
  keep["6a"] = "j"
  keep["6b"] = "k"
  keep["6c"] = "l"
  keep["6d"] = "m"
  keep["6e"] = "n"
  keep["6f"] = "o"
  keep["70"] = "p"
  keep["71"] = "q"
  keep["72"] = "r"
  keep["73"] = "s"
  keep["74"] = "t"
  keep["75"] = "u"
  keep["76"] = "v"
  keep["77"] = "w"
  keep["78"] = "x"
  keep["79"] = "y"
  keep["7a"] = "z"
  keep["7e"] = "~"
}

{
  for (i = 1; i <= NF; i++) {
    printf "%s", ($i in keep) ? keep[$i] : "%" toupper($i)
  }
}
'
}

# Decode the percent-encoded arguments, or the standard input if none, and write out the bytes as they are. Raw newlines are regarded as the terminators of encoded lines, such as the one percent_encode writes, and are discarded, so that `percent_encode | percent_decode` gives back the original bytes. A NUL byte (%00) cannot be decoded, since awk cannot handle it.
percent_decode() {
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

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (percent-encode.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  percent_encode "$@"
fi
