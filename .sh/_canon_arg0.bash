# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 44357c7 && return 0

# pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
# . ./.lib/utils.bash
# popd >/dev/null || exit 1

_canon_arg0() {
  echo "Function \"_canon_arg0\" is not implemented yet."
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  _canon_arg0 "$@"
fi
