#!/usr/bin/env bash
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ b66be82 && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  extglob "$@"
fi
