# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3f9fe75-false}" && return 0; sourced_3f9fe75=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
. ./utils.sh
. ./bindump.sh
. ./commands.sh
cd "$1" || exit 1; shift

# Get a key from the user without echoing.
get_key() {
  # Bash and BusyBox Ash provide the `-s` (silent mode) option.
  if is_bbwin || is_bash
  then
    local key
    # shellcheck disable=SC3045
    read -rsn1 key
    echo "$key"
    return
  fi
  if is_macos || is_linux
  then
    local saved_stty
    saved_stty="$(stty -g)" || return $?
    stty -icanon -echo
    dd bs=1 count=1 2>/dev/null
    stty "$saved_stty"
    return
  fi
  # Otherwise, the input is echoed
  read -r key
  echo "$key"
}

# [<message> [default]] Show a message and get input from the user.
prompt() {
  local message="${1:-Text}"
  local default="${2:-}"
  printf "%s: (%s) " "$message" "$default" >&2
  local response
  read -r response
  if test -z "$response"
  then
    response="$default"
  fi
  printf "%s" "$response"
}

# [<message> [default]] Print a message and get confirmation.
prompt_confirm() {
  local message="${1:-Text}"
  local default="${2:-n}"
  local selection
  case "$default" in
    (y|Y|yes|Yes|YES)
      default=y
      selection="Y/n"
      ;;
    (n|N|no|No|NO)
      default=n
      selection="y/N"
      ;;
    (*)
      echo "Invalid default value: $default" >&2
      return 1
  esac
  printf "%s [%s]: " "$message" "$selection" >&2
  local response
  response="$(get_key)"
  if test -z "$response"
  then
    response="$default"
  fi
  # Echoing.
  echo "$response" >&2
  case "$response" in
    (y|Y)
      return 0
      ;;
    (*)
      return 1
      ;;
  esac
}

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
    stty -icanon -echo
    s="$(
      saved_stty="$(stty -g)"
      keypress
      stty "$saved_stty"
    )"
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
