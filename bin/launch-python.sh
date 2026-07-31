# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_LAUNCH_PYTHON_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
pwd_1692d8b="$PWD"
shift 2; set -- _SCRDIR . "$@" # shpp:sources_chdir
. ./mise
cd "$3" || exit; shift 3 # /shpp:sources

launch_python() {
  cd "$pwd_1692d8b" || exit 1
  local dir="$OLDPWD"
  mise exec --cd="$dir" -- python "$@"
  cd "$dir" || exit 1
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (launch-python.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  launch_python "$@"
fi
