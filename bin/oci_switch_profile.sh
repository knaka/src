# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_860ce20-false}" && return 0; sourced_860ce20=true

# Set this script output to the OCI_PROFILE environment variable.

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/commands.sh
cd "$3" || exit; shift 3

oci_switch_profile() {
  if test $# -gt 0
  then
    profile="$1"
  else
    local unset="<UNSET>"
    set -- "$unset"
    mkdir -p "$HOME"/.oci
    touch "$HOME"/.oci/config
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
