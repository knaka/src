#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_e301601-false}" && return 0; sourced_e301601=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

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
