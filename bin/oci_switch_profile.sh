# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_OCI_SWITCH_PROFILE_SH && return # shpp:source_guard

# Set this script output to the OCI_PROFILE environment variable.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.oci_switch_profile.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  oci_switch_profile "$@"
fi
