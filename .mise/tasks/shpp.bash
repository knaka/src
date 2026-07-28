#!/usr/bin/env bash
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 6c59487 && return

pushd "${BASH_SOURCE[0]%[/\\]*}" >/dev/null 2>&1 || pushd . >/dev/null
. ../../.lib/utils.sh
popd >/dev/null || exit

shpp() {
  init_temp_dir
  local out="$TEMP_DIR"/a489fed
  local file
  for file in "$@"
  do
    test -r "$file" || continue
    file="$(realpath "$file")"
    file="${file#"$PWD/"}"
    .lib/shpp.pl "$file" >"$out"
    cat "$out" >"$file"
  done
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  shpp "$@"
fi
