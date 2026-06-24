# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 688ed4c && return 0

# pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
# . ./.lib/utils.bash
# popd >/dev/null || exit 1

_read() {
  # shopt -s lastpipe
  echo foo bar baz | {
    read -r a b c
    echo "$a"
    echo "$b"
    echo "$c"
  }
  read -r x y z < <(
    echo abc xyz zzz
  )
  echo "$x"
  echo "$y"
  echo "$z"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  _read "$@"
fi
