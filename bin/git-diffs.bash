# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 63cb631 && return 0

git_diffs() {
  git log --patch -- "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  git_diffs "$@"
fi
