# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_860ce20-false}" && return 0; sourced_860ce20=true

# Set this script output to the OCI_PROFILE environment variable.

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

oci_switch_profile() {
  if test $# -gt 0
  then
    profile="$1"
  else
    local unset="<UNSET>"
    set -- "$unset"
    # shellcheck disable=SC2046
    set -- "$@" $(sed -n -E -e 's/\[(profile )?(.*)\]/\2/p' <"$HOME"/.oci/config)
    profile="$(gum choose --selected="${OCI_PROFILE:-}" "$@")"
    test "$profile" = "$unset" && return 0
  fi
  echo "$profile"
}

case "${0##*/}" in
  (oci_switch_profile.sh|oci_switch_profile)
    set -o nounset -o errexit
    oci_switch_profile "$@"
    ;;
esac
