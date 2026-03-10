# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_0df558d-false}" && return 0; sourced_0df558d=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

add_skills() {
  local source="$1"
  shift
  local arg
  for arg in "$@"
  do
    shift
    set -- "$@" --skill "$arg"
  done
  skills add \
    "$source" \
    --global \
    --copy \
    --agent claude-code \
    "$@"
}

remove_skills() {
  local source="$1"
  shift
  local arg
  for arg in "$@"
  do
    shift
    set -- "$@" --skill "$arg"
  done
  skills remove \
    "$source" \
    --global \
    --yes \
    --agent claude-code \
    "$@"
}

# cli/skills at main · googleworkspace/cli https://github.com/googleworkspace/cli/tree/main/skills
skills_apply_gws() {
  local source="github:googleworkspace/cli"
  add_skills \
    "$source" \
    gws-shared \
    gws-gmail \
    gws-gmail-send \
    #nop
  remove_skills \
    "$source" \
    gws-gmail-watch \
    #nop
}

case "${0##*/}" in
  (skills-apply.sh|skills-apply)
    set -o nounset -o errexit
    skills_apply_gws "$@"
    ;;
esac
