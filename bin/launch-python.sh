# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_LAUNCH_PYTHON_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
. ./mise
cd "$3" || exit; shift 3 # shpp:end_source

launch_python() {
  cd "$_APPDIR" || exit 1
  local dir="$OLDPWD"
  mise exec --cd="$dir" -- python "$@"
  cd "$dir" || exit 1
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.launch-python.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  launch_python "$@"
fi
