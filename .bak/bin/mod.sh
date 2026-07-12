#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0c25e20-false}" && return 0; sourced_0c25e20=true

# List git submodules in the project dir.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
. ./git-config-list-to-json.sh
cd "$1"; shift 2

mod() {
  local prj_dir
  prj_dir="$(git rev-parse --show-toplevel 2>/dev/null)"
  local submodules
  submodules="$(git config --file "$prj_dir"/.gitmodules --list | git_config_list_to_json | jq -r '.submodule | keys[]')"
  # todo: show list to choose one?
  local arg
  # shellcheck disable=SC2086
  for arg in $submodules
  do
    echo "$prj_dir"/"$arg"
  done
}

case "${0##*/}" in
  (mod.sh|mod)
    set -o nounset -o errexit
    mod "$@"
    ;;
esac
