#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_d02645f-false}" && return 0; sourced_d02645f=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
cd "$1"; shift 2

nc_ping() {
  local port=""
  OPTIND=1; while getopts _p:-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (p|port) port="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  test -z "$port" && echo "Port not specified" >&2 && return 1
  # -z: Only  scan  for  listening daemons, without sending any data to them.  Cannot be used together with -l.
  # -v: Verbose.
  nc -z -v "$@" "$port"
}

case "${0##*/}" in
  (nc-ping.sh|nc-ping)
    set -o nounset -o errexit
    nc_ping "$@"
    ;;
esac
