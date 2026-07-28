#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_HTTPD_MINI_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
. ../.lib/ip.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # shpp:end_source

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.httpd-mini.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  httpd_mini "$@"
fi
