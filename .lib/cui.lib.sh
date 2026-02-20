# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3f9fe75-false}" && return 0; sourced_3f9fe75=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
. ./utils.lib.sh
. ./bindump.lib.sh
. ./commands.lib.sh
shift 2
cd "$1" || exit 1; shift

# Alternative `gum choose` which takes value not label for `--selected=...`.
# - gum choose label:value options use value for --selected · Issue #958 · charmbracelet/gum https://github.com/charmbracelet/gum/issues/958
choose() {
  local arg
  local scanning_items=false
  local label_delimiter=
  local selected=
  for arg in "$@"
  do
    shift
    if ! "$scanning_items"
    then
      case "$arg" in
        (--label-delimiter=*) label_delimiter="${arg#*=}";;
        (--selected=*)
          selected="${arg#*=}"
          continue
          ;;
        (-*) ;;
        (*) scanning_items=true;;
      esac
    fi
    if "$scanning_items" && test -n "$label_delimiter" -a -n "$selected"
    then
      local value="${arg#*"$label_delimiter"}"
      local label="${arg%"$label_delimiter"*}"
      test "$value" = "$selected" && selected="$label"
    fi
    set -- "$@" "$arg"
  done
  test -n "$selected" && set -- --selected="$selected" "$@"
  gum choose "$@"
}

# Horizontal "choose"
hchoose() {
  local selected=""
  local header="Choose:"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (selected) selected="$OPTARG";;
      (header) header="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  red=$(printf "\033[31m")
  normal=$(printf "\033[00m")

  local i=1
  local j=1
  local arg
  for arg in "$@"
  do
    if test "$arg" = "$selected"
    then
      i="$j"
      break
    fi
    j=$((j + 1))
  done

  while :
  do
    printf "%s" "$header" >&2
    local j=1
    for arg in "$@"
    do
      if test "$i" -eq "$j"
      then
        printf "%s[%s]%s" "$red" "$arg" "$normal" >&2
      else
        printf " %s " "$arg" >&2
      fi
      j=$((j + 1))
    done
    printf "\r" >&2
    local s
    s="$(get_key)"
    if test -z "$s"
    then
      shift $((i - 1))
      printf '%s' "$1"
      echo >&2
      return
    fi
    local x
    x="$(printf "%s" "$s" | hex_dump)"
    if test "$x" = "1b "
    then
      s="$s$(get_key)$(get_key)"
      x="$(printf "%s" "$s" | hex_dump)"
    fi
    case "$x" in
      ("1b 5b 44 "|"02 ") # Left
        if test "$i" -gt 1
        then
          i=$((i - 1))
        fi
        ;;
      ("1b 5b 43 "|"06 ") # Right
        if test "$i" -lt $#
        then
          i=$((i + 1))
        fi
        ;;
      (*) ;;
    esac
  done
}

# Horizontal "choose"
choosex() {
  local selected=""
  local header="Choose:"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (selected) selected="$OPTARG";;
      (header) header="$OPTARG";;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  red=$(printf "\033[31m")
  normal=$(printf "\033[00m")

  local i=1
  local j=1
  local arg
  for arg in "$@"
  do
    if test "$arg" = "$selected"
    then
      i="$j"
      break
    fi
    j=$((j + 1))
  done

  while :
  do
    printf "%s" "$header" >&2
    local j=1
    for arg in "$@"
    do
      if test "$i" -eq "$j"
      then
        printf "%s[%s]%s" "$red" "$arg" "$normal" >&2
      else
        printf " %s " "$arg" >&2
      fi
      j=$((j + 1))
    done
    if is_windows
    then
      printf "\n" >&2
    else
      printf "\r" >&2
    fi
    local s
    s="$(keypress)"
    if test "$s" = "enter"
    then
      shift $((i - 1))
      printf '%s' "$1"
      echo >&2
      return
    fi
    case "$s" in
      (left|ctrl+b) # Left
        if test "$i" -gt 1
        then
          i=$((i - 1))
        fi
        ;;
      (right|ctrl+f) # Right
        if test "$i" -lt $#
        then
          i=$((i + 1))
        fi
        ;;
      (*) ;;
    esac
  done
}
