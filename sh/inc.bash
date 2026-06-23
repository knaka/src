#!/usr/bin/env bash
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_loaded() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _loaded f276ebe && return 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
. ./foo-dir/foo.lib.bash
. ./foo-dir/bar-dir/bar.lib.bash
popd >/dev/null || exit 1

inc-2() {
  echo "Function \"inc-2\" is not implemented yet."

  echo "${aaa[@]-}"

  # _sourced+="9cbce50"
  # _sourced+="05d62fb"
  # echo _sourced: "${_sourced[*]}"
  # sourced_has 05d62fb
  # printf "%s\n" " ${_sourced[*]} "
  # if [[ "${_sourced[*]}" == *05d62fb* ]]
  # then
  #   echo found
  # fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  inc-2 "$@"
fi
