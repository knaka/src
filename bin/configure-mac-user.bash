#!/usr/bin/env bash
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_loaded() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _loaded 191d016 && return 0

pushd "${BASH_SOURCE[0]%[/\\]*}" >/dev/null 2>&1 || pushd . >/dev/null
. ../.lib/utils.sh
. ./ext2uti.bash
popd >/dev/null || exit

configure_mac_user() {
  is_macos || return 1

  # Associate specific file extensions with the editor.
  local exts=(
    .bash
    .md
    .sh
    .txt
  )
  if ! has_external_command duti
  then
    echo 'This script requires "duti" command installed.' >&2
    exit 1
  fi
  local editor_app_path="/Applications/Visual Studio Code.app"
  test -d "$editor_app_path" || return 1
  local editor_info_path="$editor_app_path"/Contents/Info.plist
  local editor_bundle_id
  editor_bundle_id="$(defaults read "$editor_info_path" CFBundleIdentifier)"
  local ext
  for ext in "${exts[@]}"
  do
    local uti
    uti="$(ext2uti "$ext")"
    echo "ext: $ext -> uti: $uti" >&2
    duti -s "$editor_bundle_id" "$uti" all
  done
  for ext in "${exts[@]}"
  do
    echo "$ext:"
    duti -x "$ext" | sed -e 's/^/  /'
  done
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  configure_mac_user "$@"
fi
