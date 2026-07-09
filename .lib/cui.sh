# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3f9fe75-false}" && return 0; sourced_3f9fe75=true

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./utils.sh
test -r ./commands.sh && . ./commands.sh
shift 2
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
