#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_CONF_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # shpp:end_source

conf() {
  local source_path="$HOME"/.local/share/chezmoi
  local mode="file"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (source) source_path="$OPTARG";;
      (mode) mode="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; exit 1;;
    esac
  done

  local found_subcmd=false
  local arg
  for arg in "$@"
  do
    shift
    if ! "$found_subcmd"
    then
      case "${arg}" in
        (-*)
          ;;
        (*)
          found_subcmd=true
          set -- "$@" --mode="$mode" --source="$source_path"
          case "$arg" in
            (ed|edit)
              set -- "$@" edit --watch
              continue
              ;;
            (*)
              ;;
          esac
          ;;
      esac
    fi
    set -- "$@" "$arg"
  done
  chezmoi "$@"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.conf.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  set -- --source="$HOME/repos/github.com/knaka/src/conf/source" "$@"
  set -- --mode="symlink" "$@"
  conf "$@"
fi
