# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
"${sourced_21fac06-false}" && return 0; sourced_21fac06=true

pushd "${BASH_SOURCE[0]%/*}" >/dev/null 2>&1 || pushd . >/dev/null
popd >/dev/null || exit 1

loop() {
  local id="${1-N/A}"
  while :
  do
    echo -n "$id: "
    date
    echo Sleeping... >&2
    sleep 1
  done
}

case "${0##*/}" in
  ("${BASH_SOURCE[0]##*/}"|"${BASH_SOURCE[0]##*/}".bash)
    set -o nounset -o errexit -o pipefail
    loop "$@"
    ;;
esac
