#!/usr/bin/env bash
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_loaded() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _loaded 191d016 && return 0

{ pushd "${BASH_SOURCE[0]%/*}" || pushd "${BASH_SOURCE[0]%\\*}" || pushd .; } >/dev/null 2>&1
#set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
# shift 2
. ./ext2uti.bash
popd >/dev/null || exit 1

exts_0c74d9e=(
  .txt
  .sh
  .bash
)

configure_mac_user() {
  is_macos || return 1
  local editor_app="/Applications/Visual Studio Code.app"
  test -d "$editor_app" || return 1
  local info_path="$editor_app"/Contents/Info.plist
  local bundle_id
  bundle_id="$(defaults read "$info_path" CFBundleIdentifier)"
  local ext
  for ext in "${exts_0c74d9e[@]}"
  do
    local uti
    uti="$(ext2uti "$ext")"
    echo "ext: $ext -> uti: $uti" >&2
    duti -s "$bundle_id" "$uti" all
  done
  for ext in "${exts_0c74d9e[@]}"
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
