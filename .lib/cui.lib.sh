# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3f9fe75-false}" && return 0; sourced_3f9fe75=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
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
