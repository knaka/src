# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 70b210b && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./.lib/utils.bash
set -- _LIBDIR .lib "$@"
. ./.lib/embed-script.lib.sh
shift 2
popd >/dev/null || exit 1

embed-minified() {
  embed_minified "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  embed-minified "$@"
fi
