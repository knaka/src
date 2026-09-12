#!/usr/bin/env bash
set -- _a5d3dd5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/commands.sh
popd >/dev/null || exit

conf() {
  local source_path="$HOME"/.local/share/chezmoi
  local mode="file"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (help) chezmoi --help; return;;
      (version) chezmoi --version; return;;
      (mode) mode="$OPTARG";;
      (source) source_path="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  local -a global_opts=(--mode="$mode" --source="$source_path")
  local found_subcmd=false
  local arg
  for arg in "$@"
  do
    shift
    if ! "$found_subcmd"
    then
      case "${arg}" in
        (-*)
          global_opts+=("$arg")
          continue
          ;;
        (*)
          found_subcmd=true
          case "$arg" in
            (add)
              if test $# -gt 0
              then
                set -- "$@" add
              else
                set -- "$@" re-add
              fi
              continue
              ;;
            (diff)
              set -- "$@" diff --reverse
              continue
              ;;
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
  
  chezmoi "${global_opts[@]}" "$@"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit
  set -- --source="$HOME/repos/github.com/knaka/src/conf/source" "$@"
  # set -- --mode="symlink" "$@"
  set -- --mode="file" "$@"
  TAIL_DEPTH=1 conf "$@"
fi
