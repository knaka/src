#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_35deb9f-false}" && return 0; sourced_35deb9f=true

# Replace four-space indents at the beginning of lines with two-space indents.

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

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
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done

  if "$shows_diff"
  then
    init_temp_dir
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

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ four_to_two
then
  set -o nounset -o errexit
  four_to_two "$@"
fi
