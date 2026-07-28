#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_CALC_SH && return # shpp:source_guard

# expression=$(echo "$@" | perl -pe 's/,([[:digit:]]{3})/\1/g')
# perl -e "print (\"$* -> \" . (${expression}) . \"\n\");"

printf "%s" "$* -> "
printf "%s" "$*" | bc
