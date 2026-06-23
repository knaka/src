# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_loaded() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1 ${_ids-}"; false;; esac; }; _loaded 708daa5 && return 0

echo foo

pushd "${BASH_SOURCE[0]%/*}" >/dev/null || exit 1
. ./bar-dir/bar.lib.bash
. ./bar-dir/bar.lib.bash
popd >/dev/null || exit 1
