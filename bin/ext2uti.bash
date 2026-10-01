#!/usr/bin/env bash
set -- _BIN_EXT2UTI_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# File extension to UTI // Uniform Type Identifier - Wikipedia https://en.wikipedia.org/wiki/Uniform_Type_Identifier

# File ext to UTI
ext2uti() {
  is_macos || return 1
  test $# -eq 0 && return 1
  init_temp_dir
  local ext
  ext="$1"
  test -z "$ext" && return 1
  [[ "$ext" =~ ^\. ]] || ext=."$ext"
  local file="$TEMP_DIR"/f5d9634"$ext"
  touch "$file"
  local uti
  # Ask Spotlight for the content type of the empty dummy file, which macOS infers from its extension. `-raw` prints the bare value without the "kMDItemContentType = " prefix and quotes, or "(null)" if the attribute is unavailable.
  uti="$(mdls -raw -name kMDItemContentType "$file")"
  if test -z "$uti" || test "$uti" = "(null)" || [[ "$uti" =~ ^dyn\. ]]
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
