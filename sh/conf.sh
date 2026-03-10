# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_88f1f74-false}" && return 0; sourced_88f1f74=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

conf() {
  local source_path="$HOME"/.local/share/chezmoi
  local mode="file"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (source) source_path="$OPTARG";;
      (mode) mode="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

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

case "${0##*/}" in
  (conf.sh|conf)
    set -o nounset -o errexit
    conf \
      --source="$HOME/repos/github.com/knaka/src/conf/source" \
      --mode="symlink" \
      "$@"
    ;;
esac
