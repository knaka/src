#!/usr/bin/env bash
set -- _00270f2 "$@"; eval "shift; \${$1-false} || ! $1=true" && return

#MISE description="[files...] SHell PreProcessor. If no filenames are provided, all files listed in $LSV_SHPP_TARGETS are processed."

pushd "${BASH_SOURCE[0]%[/\\]*}" >/dev/null 2>&1 || pushd . >/dev/null
. ../../.lib/utils.sh
. ../../.lib/cui.sh
assets_path_c3e24bd="$PWD"/.assets
popd >/dev/null || exit

: "${LSV_SHPP_TARGETS=}"

shpp() {
  init_temp_dir
  local out="$TEMP_DIR"/a489fed
  local pwd
  pwd="$(realpath "$PWD")"
  local file
  for file in "$@"
  do
    test -r "$file" || continue
    file="$(realpath "$file")"
    file="${file#"$pwd/"}"
    perl "$assets_path_c3e24bd"/_shpp.pl --in-place "$file" >"$out"
  done
}

main_4a10603() {
  if test $# -eq 0
  then
    local IFS
    local disable_noglob=false
    case $- in (*f*) ;; (*) set -o noglob; disable_noglob=true;; esac
    IFS="$CH_LF"
    # shellcheck disable=SC2086
    set -- $LSV_SHPP_TARGETS
    "$disable_noglob" && set +o noglob
    # shellcheck disable=SC2046
    set -- $(extglob "$@")
    unset IFS
    if is_terminal
    then
      echo "$@" >&2
      prompt_confirm "Process for $# files?" || return
    fi
  fi
  shpp "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  main_4a10603 "$@"
fi
