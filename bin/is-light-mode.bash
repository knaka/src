#!/usr/bin/env bash
set -- _BIN_IS_LIGHT_MODE_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Check if the terminal has a light background by asking it for the background color. Succeed if the color is light, and fail if the color is dark or the terminal does not reply.

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

# OSC 11 with "?": Ask the terminal for its background color.
# Build it with printf(1), since static analysis somehow fails when this is written as a literal in the $'...' form.
# shellcheck disable=SC1003
printf -v osc_query_background '\033]11;?\033\\'
readonly osc_query_background

result_0f11d2b=

terminal_color_scheme_8823bbd_() {
  result_0f11d2b=
  local fixed_wait=false
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (fixed-wait) fixed_wait=true;;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  local saved
  saved="$(stty -g </dev/tty)" || return 1
  local reply=
  if is_bash_bin 4
  then
    stty raw -echo </dev/tty
    printf '%s' "$osc_query_background" >/dev/tty
    # Since Bash 4, the timeout can be fractional, and the partial input is kept in the variable even if the reply does not end with a backslash.
    local backslash
    # shellcheck disable=SC1003
    printf -v backslash '\'
    IFS= read -r -t 0.1 -d "$backslash" reply </dev/tty || true
  elif "$fixed_wait"
  then
    # min 0 time 1: End reading after 0.1 seconds without input, since `read -t` of Bash 3 cannot wait for less than a second, and some terminals do not end the reply with a backslash. Do not pass `-d` to `read`, which would override these settings.
    stty raw -echo min 0 time 1 </dev/tty
    printf '%s' "$osc_query_background" >/dev/tty
    IFS= read -r reply </dev/tty || true
  else
    stty raw -echo min 0 time 0 </dev/tty
    printf '%s' "$osc_query_background" >/dev/tty
    local chunk i=0
    while test "$i" -lt 50
    do
      IFS= read -r chunk </dev/tty || true
      reply="$reply$chunk"
      case "$reply" in
        (*$'\033'\\*|*$'\a'*)
          break;;
      esac
      sleep 0.01
      i=$((i + 1))
    done
  fi
  stty "$saved" </dev/tty
  case "$reply" in
    (*rgb:[cdef]*/[cdef]*/[cdef]*)
      result_0f11d2b=light
      ;;
    (*rgb:*)
      result_0f11d2b=dark
      ;;
    (*)
      ;;
  esac
}

terminal_color_scheme_() {
  terminal_color_scheme_8823bbd_ "$@"
  set_ "$result_0f11d2b"
}

is_light_mode() {
  terminal_color_scheme_8823bbd_ "$@"
  case "$result_0f11d2b" in
    (light) return 0;;
  esac
  return 1
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 is_light_mode "$@"
fi
