#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_CALC_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# expression=$(echo "$@" | perl -pe 's/,([[:digit:]]{3})/\1/g')
# perl -e "print (\"$* -> \" . (${expression}) . \"\n\");"

printf "%s" "$* -> "
printf "%s" "$*" | bc
