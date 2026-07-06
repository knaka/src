# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ e37f570 && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2

: "${answer1_dc26821:=}"

set_user_answers() {
  test "${answer2_91cc2eb+set}" = set || return 1
  answer1_dc26821="$(gum input)"
  answer2_91cc2eb="$(gum input)"
}

set_default_answers() {
  answer1_dc26821="DEFAULT ANSWER 1"
  answer2_91cc2eb="DEFAULT ANSWER 2"
}

multiret() {
  local answer2_91cc2eb
  set_user_answers
  test -z "$answer1_dc26821" -o -z "$answer2_91cc2eb" && set_default_answers
  echo "$answer1_dc26821, $answer2_91cc2eb"
}

case "${0##*/}" in
  (multiret.sh|multiret)
    set -o nounset -o errexit
    multiret "$@"
    ;;
esac
