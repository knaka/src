#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5fdc113-false}" && return 0; sourced_5fdc113=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
  init_temp_dir
. ./ip-utils.lib.sh
  init_ports_used_in_session_path
. ./caddy.lib.sh
cd "$1"; shift 2

httpd_mini() {
  local dir="$PWD"
  if test "${1+set}" = set
  then
    dir="$1"
  fi
  dir="$(realpath "$dir")"
  local host=127.0.0.1
  local port="$(ip_random_free_port)"
  local url="http://$host:$port"
  echo "HTTP Server running at $url , providing the content of the directory $dir ."
  caddy file-server --listen="$host":"$port" --browse --root="$dir"
}

case "${0##*/}" in
  (httpd-mini.sh|httpd-mini)
    set -o nounset -o errexit
    httpd_mini "$@"
    ;;
esac
