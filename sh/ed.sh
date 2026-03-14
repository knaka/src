# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_569237b-false}" && return 0; sourced_569237b=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
# . ./conf.sh
. ./edr.sh
cd "$1" || exit 1; shift 2

# bar cafead0abc

should_block_b69939e=false

edit_file() {
  # Path for VSCode has disappeared from $PATH ... ???
  if first_call 07bedbc && is_windows
  then
    export PATH="$PATH:$LOCALAPPDATA/Programs/Microsoft VS Code"
  fi
  if command -v code >/dev/null 2>&1
  then
    if $should_block_b69939e
    then
      set -- --wait "$@"
    fi
    code "$@"
  else
    "$EDITOR" "$@"
  fi
}

ed() {
  local dereference=false
  local raw=false
  OPTIND=1; while getopts _-:Lr OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (b|block|w|wait) should_block_b69939e=true;;
      (L|dereference) dereference=true;;
      (r|raw) raw=true;;
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
        local color=
        local red="#efafaf"
        local green="#afefaf"
        local blue="#afafef"
        local yellow="#efefaf"
        local magenta="#efafef"
        local cyan="#afefef"
        case "$arg" in
          (d8f0794|"$HOME"/repos/github.com/knaka/src) color="$red";;
          (8182711) color="$green";;
          (187f091) color="$blue";;
          (a5bf109|"$HOME"/MyDrive/doc) color="$yellow";;
          (ba8454d) color="$magenta";;
          (bb67412) color="$cyan";;
          (*) ;;
        esac
        if test -n "$color"
        then
          local base
          base="$(basename "$arg")"
          local dir="$HOME/.cache/code-workspaces"
          mkdir -p "$dir"
          local file="$dir"/"$base".code-workspace
          jq -n -c \
          --arg path "$arg" \
          --arg color "$color" \
          '
            {
              "folders": [
                { "path": $path }
              ],
              "settings": {
                "workbench.colorCustomizations": {
                  "activityBar.background": $color,
                  "statusBar.background": $color,
                  "titleBar.activeBackground": $color,
                  "titleBar.inactiveBackground": $color,
                }
              }
            }
          ' \
          >"$file"
          arg="$file"
        fi
      # File exists
      elif test -f "$arg"
      then
        # Resolve only directory, so that editors open the file symlink as it appears in the directory
        local arg_dir
        local arg_base
        arg_dir="$(dirname "$arg")"
        arg_base="$(basename "$arg")"
        arg="$(realpath "$arg_dir")"/"$arg_base"
        if "$dereference"
        then
          arg="$(realpath "$arg")"
        fi
        if "$raw"
        then
          edr "$arg"
          continue
        fi
        # case "$arg" in
        #   (${HOME}/.*)
        #     if \
        #       echo "$arg" \
        #       | grep -q \
        #         -e "node_modules"
        #     then
        #       :
        #     else
        #       printf "%s seems to be a dot file. " "$arg" >&2
        #       if prompt_confirm "Edit as a configuration file?" "y" >&2
        #       then
        #         conf edit "$arg"
        #         continue
        #       fi
        #     fi
        #     ;;
        # esac
      # Other type, then exit as error
      else
        exit 1
      fi
    # Not exists
    else
      # Resolve only directory symlinks, as the file is to be created
      local arg_dir
      local arg_base
      arg_dir="$(dirname "$arg")"
      arg_base="$(basename "$arg")"
      arg="$(realpath "$arg_dir")"/"$arg_base"
      if "$dereference"
      then
        arg="$(realpath "$arg")"
      fi
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
    edit_file "$arg"
  done
}

case "${0##*/}" in
  (ed.sh|ed)
    set -o nounset -o errexit
    ed "$@"
    ;;
esac
