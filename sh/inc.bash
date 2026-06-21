#!/usr/bin/env bash
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash

echo "${BASH_SOURCE[0]%/*}"
echo "${BASH_SOURCE[0]%/*}"
exit 0

pushd "${BASH_SOURCE[0]%/*}" >/dev/null || exit 1
. ./foo-dir/foo.lib.bash
. ./foo-dir/bar-dir/bar.lib.bash
popd >/dev/null || exit 1

inc-2() {
  echo "Function \"inc-2\" is not implemented yet."
}

echo f16871c "${0##*/}"
case "${0##*/}" in
  (inc.bash|inc)
    set -o nounset -o errexit
    inc-2 "$@"
    ;;
esac
