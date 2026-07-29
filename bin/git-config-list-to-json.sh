#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_GIT_CONFIG_LIST_TO_JSON_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.git-config-list-to-json.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  git_config_list_to_json "$@"
fi
