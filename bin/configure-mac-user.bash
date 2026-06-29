# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 66135c5 && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
. ./ext2uti.bash
popd >/dev/null || exit 1

exts=(
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
  for ext in "${exts[@]}"
  do
    local uti
    uti="$(ext2uti "$ext")"
    echo "ext: $ext -> uti: $uti" >&2
    duti -s "$bundle_id" "$uti" all
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
