# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ c4b2b54 && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
popd >/dev/null || exit 1

ext2uti() {
  is_macos || return 1
  test $# -eq 0 && return 1
  init_temp
  local ext
  ext="$1"
  test -z "$ext" && return 1
  [[ "$ext" =~ ^\. ]] || ext=."$ext"
  local file="$TEMP_DIR"/f5d9634"$ext"
  touch "$file"
  local uti
  uti="$(
    mdls -name kMDItemContentType -name kMDItemContentTypeTree "$file" \
    | perl -ne 'if (/kMDItemContentType *= *"(.*)"/) { print $1 };'
  )"
  if test -z "$uti" || [[ "$uti" =~ ^dyn\. ]]
  then
    echo UTI for "$ext" not found. >&2
    return 1
  fi
  echo "$uti"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  ext2uti "$@"
fi
