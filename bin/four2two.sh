#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_FOUR2TWO_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# Replace four-space indents at the beginning of lines with two-space indents.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

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

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (four2two.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  four_to_two "$@"
fi
