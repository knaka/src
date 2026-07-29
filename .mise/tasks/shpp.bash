#!/usr/bin/env bash
set -- _00270f2 "$@"; eval "shift; \${$1-false} || ! $1=true" && return

pushd "${BASH_SOURCE[0]%[/\\]*}" >/dev/null 2>&1 || pushd . >/dev/null
. ../../.lib/utils.sh
. ../../.lib/cui.sh
popd >/dev/null || exit

: "${LSV_SHPP_TARGETS=}"

shpp() {
  if test $# -eq 0
  then
    local IFS
    local disable_noglob=false
    case $- in (*f*) ;; (*) set -o noglob; disable_noglob=true;; esac
    IFS="$CH_LF"
    # shellcheck disable=SC2086
    set -- $LSV_SHPP_TARGETS
    # shellcheck disable=SC2046
    set -- $(extglob "$@")
    unset IFS
    "$disable_noglob" && set +o noglob
    if is_terminal
    then
      prompt_confirm "Process for $# files?" || return
    fi
  fi
  init_temp_dir
  local out="$TEMP_DIR"/a489fed
  local file
  for file in "$@"
  do
    test -r "$file" || continue
    local base="${file%[/\\]*}"
    case "$base" in
      (\
        "touchsh.sh"|\
        "touchbash.bash"|\
        "_28c2f64_"\
      ) continue;;
    esac
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
