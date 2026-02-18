#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5fdc113-false}" && return 0; sourced_5fdc113=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/ip-utils.lib.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

httpd_mini() {
  local dir="$PWD"
  test $# -gt 0 && dir="$1"
  dir="$(realpath "$dir")"
  local host=127.0.0.1
  local port="$(ip_random_free_port)"
  local url="http://$host:$port"
  echo "HTTP Server running at $url , providing the content of the directory $dir ."
  # -b, --browse: Enable directory browsing
  caddy file-server --listen="$host":"$port" --browse --root="$dir"
}

case "${0##*/}" in
  (httpd-mini.sh|httpd-mini)
    set -o nounset -o errexit
    httpd_mini "$@"
    ;;
esac
