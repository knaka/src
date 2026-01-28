#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_569237b-false}" && return 0; sourced_569237b=true

set -- "$PWD" "${0%/*}" "$@"; if test "$2" != "$0"; then cd "$2" 2>/dev/null || :; fi
. ./task.sh
. ./conf.sh
cd "$1"; shift 2

should_block=false

edit_it() {
  # Path for VSCode has disappeared from $PATH ... ???
  if first_call 07bedbc && is_windows
  then
    export PATH="$PATH:$LOCALAPPDATA/Programs/Microsoft VS Code"
  fi
  if command -v code >/dev/null 2>&1
  then
    if $should_block
    then
      set -- --wait "$@"
    fi
    code "$@"
  else
    "$EDITOR" "$@"
  fi
}

ed() {
  OPTIND=1; while getopts b-: OPT
  do
    if test "$OPT" = "-"
    then
      OPT="${OPTARG%%=*}"
      # shellcheck disable=SC2030
      OPTARG="${OPTARG#"$OPT"}"
      OPTARG="${OPTARG#=}"
    fi
    case "$OPT" in
      (b|block|w|wait) should_block=true;;
      (\?) exit 1;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  local arg
  for arg in "$@"
  do
    # Exists
    if test -e "$arg"
    then
      # Directory exists
      if test -d "$arg"
      then
        printf "%s is a directory. " "$arg" >&2
        if ! prompt_confirm "Open?" "n" >&2
        then
          exit 0
        fi
        # It is preferable to open the workspace with the actual path rather than the symlink location. Otherwise, when tools open FILES with real paths, they may not recognize them as being within the workspace directory.
        arg="$(realpath "$arg")"
      # File exists
      elif test -f "$arg"
      then
        # Resolve only directory.
        local dir="$(dirname "$arg")"
        local base="$(basename "$arg")"
        arg="$(realpath "$dir")"/"$base"
        case "$arg" in
          (${HOME}/.*)
            printf "%s seems to be a dot file. " "$arg" >&2
            if prompt_confirm "Edit as a configuration file?" "y" >&2
            then
              conf edit "$arg"
              continue
            fi
            ;;
        esac
      # Other type, then exit as error
      else
        exit 1
      fi
    # Not exists
    else
      # Resolve only directory symlinks, as the file does not exist
      local arg_dir="$(realpath "$(dirname "$arg")")"
      local arg_base="$(basename "$arg")"
      arg="$arg_dir/$arg_base"
      if ! test -e "$arg"
      then
        printf "File %s does not exist. " "$arg" >&2
        if ! prompt_confirm "Create?" "n" >&2
        then
          exit 0
        fi
        mkdir -p "$arg_dir"
        touch "$arg"
      fi
    fi
    shift
    edit_it "$arg"
  done
}

case "${0##*/}" in
  (ed.sh|ed)
    set -o nounset -o errexit
    ed "$@"
    ;;
esac
