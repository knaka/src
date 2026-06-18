# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ce86c4b-false}" && return 0; sourced_ce86c4b=true

#MISE description="Generate Mise bootstrap scripts."

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$1" || exit 1; shift 2

generate() {
  cd "$MISE_ORIGINAL_CWD" || exit 1
  local ver="$(mise version | cut -d' ' -f1)"
  pwd
  sed -e "s/__MISE_VERSION__/$ver/" "$_APPDIR"/_mise >mise
  chmod +x mise
  sed -e "s/__MISE_VERSION__/$ver/" "$_APPDIR"/_mise.cmd >mise.cmd
  cd "$OLDPWD" || exit 1
}

case "${0##*/}" in
  (generate.sh|generate)
    set -o nounset -o errexit
    generate "$@"
    ;;
esac
