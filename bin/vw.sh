# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_VW_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # shpp:end_source

vw() {
  init_temp_dir
  local title="(stdin)"
  if test $# -ge 1
  then
    title="$(basename "$1") (RO)"
  fi
  local file_path="$TEMP_DIR"/"$title"
  cat "$@" >"$file_path"
  chmod 444 "$file_path"
  ed --block "$file_path"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.vw.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  vw "$@"
fi
