# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0df558d-false}" && return 0; sourced_0df558d=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

skills_add_b61e4de() {
  local source="$1"
  shift
  local arg
  while test "$1" != "--skill"
  do
    arg="$1"
    shift
    if test "$arg" = "--add"
    then
      local val="$1"
      shift
      set -- "$@" --skill "$val"
    else
      shift
    fi
  done
  skills add \
    "$source" \
    --global \
    --copy \
    --agent claude-code \
    "$@"
}

skills_remove_217f03b() {
  local source="$1"
  shift
  local arg
  while test "$1" != "--skill"
  do
    arg="$1"
    shift
    if test "$arg" = "--remove"
    then
      local val="$1"
      shift
      set -- "$@" --skill "$val"
    else
      shift
    fi
  done
  skills remove \
    "$source" \
    --global \
    --yes \
    --agent claude-code \
    "$@"
}

skills_apply() {
  skills_add_b61e4de "$@"
  skills_remove_217f03b "$@"
}

case "${0##*/}" in
  (skills-apply.sh|skills-apply)
    set -o nounset -o errexit
    # cli/skills at main · googleworkspace/cli https://github.com/googleworkspace/cli/tree/main/skills
    skills_apply \
      "github:googleworkspace/cli" \
      --add gws-shared \
      --add gws-gmail \
      --add gws-gmail-send \
      --remove gws-chat \
      #nop
    ;;
esac
