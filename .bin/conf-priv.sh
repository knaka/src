# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f5377c0-false}" && return 0; sourced_f5377c0=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
. ./conf.sh
cd "$1" || exit 1; shift 2

conf_priv() {
  conf \
    --source="$HOME/repos/github.com/knaka/src-priv/conf/source" \
    --mode="symlink" \
    "$@"
}

case "${0##*/}" in
  (conf-priv.sh|conf-priv)
    set -o nounset -o errexit
    conf_priv "$@"
    ;;
esac
