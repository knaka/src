# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_daf0894-false}" && return 0; sourced_daf0894=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ./mise
cd "$3" || exit; shift 3

launch_python() {
  cd "$_APPDIR" || exit 1
  local dir="$OLDPWD"
  mise exec --cd="$dir" -- python "$@"
  cd "$dir" || exit 1
}

case "${0##*/}" in
  (launch-python.sh|launch-python)
    set -o nounset -o errexit
    launch_python "$@"
    ;;
esac
