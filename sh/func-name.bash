#!/usr/bin/env bash
set -- _986c663 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/time.sh
popd >/dev/null || exit

func_name() {
  echo "$(date_iso): 713c88c ${FUNCNAME[0]}" >&2
  echo "Function \"func_name\" is not implemented yet."
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 func_name "$@"
fi
