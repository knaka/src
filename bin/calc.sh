#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 1b5b685 && return 0

# expression=$(echo "$@" | perl -pe 's/,([[:digit:]]{3})/\1/g')
# perl -e "print (\"$* -> \" . (${expression}) . \"\n\");"

printf "%s" "$* -> "
printf "%s" "$*" | bc
