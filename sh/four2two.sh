#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_35deb9f-false}" && return 0; sourced_35deb9f=true

# Replace four-space indents at the beginning of lines with two-space indents.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
shift 2
cd "$1" || exit 1; shift 2

replace_eee0bbd() {
  sed -E -e ':a' -e 's/^((    )*)    /\1\n/; ta' -e 's/\n/  /g'
}

four_to_two() {
  local shows_diff=false
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (d|diff) shows_diff=true;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  if "$shows_diff"
  then
    register_temp_cleanup
    local source_file="$TEMP_DIR/source-$$.tmp"
    local dest_file="$TEMP_DIR/dest-$$.tmp"
    cat >"$source_file"
    replace_eee0bbd <"$source_file" >"$dest_file"
    if "${PAGER:+set}" != set
    then
      PAGER=less
    fi
    diff "$source_file" "$dest_file" | "$PAGER"
  else
    replace_eee0bbd
  fi
}

case "${0##*/}" in
  (four2two.sh|four2two)
    set -o nounset -o errexit
    four_to_two "$@"
    ;;
esac
