# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ a71a656 && return 0

# pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
# . ./.lib/utils.bash
# popd >/dev/null || exit 1

SIGPIPE=13
rc_sigpipe=$((128 + SIGPIPE))

_sigpipe() {
  seq 1000000 | head -n 10 || test $? -eq "$rc_sigpipe"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  _sigpipe "$@"
fi
