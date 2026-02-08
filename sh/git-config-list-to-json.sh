#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e301601-false}" && return 0; sourced_e301601=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./task.sh
cd "$1"; shift 2

# Converts `git config --list` output into a JSON object.
# Reads key=value lines from stdin, splits keys by dots, and builds a nested JSON object.
#
# Usage:
#   git config ... --list | git-config-list-to-json
#
# Limitations:
#   - Values containing newlines are not handled correctly.
#   - Duplicate keys are overwritten by the last occurrence.
#   - Section names containing dots are not parsed correctly.

git_config_list_to_json() {
  # reduce: The reduce syntax allows you to combine all of the results of an expression by accumulating them into a single answer. The form is reduce EXP as $var (INIT; UPDATE).  —  https://jqlang.org/manual/#reduce
  # inputs: Outputs all remaining inputs, one by one. — https://jqlang.org/manual/#inputs
  # setpath: The builtin function setpath sets the PATHS in . to VALUE. — https://jqlang.org/manual/#setpath
  jq --raw-input --slurp --null-input '
reduce
  (
    inputs
    | split("\n")[]
    | select(length > 0)
  ) as $line
  (
    {};
    ($line | split("=")) as $kv
    | ($kv[0] | split(".")) as $path
    | setpath($path; $kv[1])
  )
'
}

case "${0##*/}" in
  (git-config-list-to-json.sh|git-config-list-to-json)
    set -o nounset -o errexit
    git_config_list_to_json "$@"
    ;;
esac
