#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5fdc113-false}" && return 0; sourced_5fdc113=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/ip.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3

httpd_mini() {
  local dir="$PWD"
  test $# -gt 0 && dir="$1"
  dir="$(realpath "$dir")"
  local host=127.0.0.1
  local port
  port="$(ip_random_free_port)"
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
