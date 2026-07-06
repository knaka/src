#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_9913f0e-false}" && return 0; sourced_9913f0e=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

run_mise() {
  if test $# = 0
  then
    mise tasks
  else
    local subcmd="$1"
    shift
    mise run "$subcmd" "$@"
  fi
}

is_mise_project_dir() {
  local dir=.
  test $# -gt 0 && dir="$1"
  # Configuration | mise-en-place https://mise.jdx.dev/configuration.html
    test -r "$dir"/mise.local.toml \
  || test -r "$dir"/mise.toml \
  || test -r "$dir"/mise/config.toml \
  || test -r "$dir"/.mise/config.toml \
  || test -r "$dir"/.config/mise.toml \
  || test -r "$dir"/.config/mise/config.toml \
  || test -d "$dir"/.config/mise/conf.d \
  #nop
}

t() {
  if is_windows
  then
    # Marker
    export executed_thru_t_bb789ec=true
  fi
  local original_pwd="$PWD"
  while :
  do
    if is_mise_project_dir
    then
      if test -x ./task
      then
        cmd="$PWD"/task
        cd "$original_pwd" || return 1
        "$cmd" "$@"
        return $?
      else
        cd "$original_pwd" || return 1
        mise run "$@"
        return $?
      fi
    fi
    cd ..
    if test "$PWD" = "$OLDPWD"
    then
      echo Reached to the root. >&2
      return 1
    fi
  done
}

case "${0##*/}" in
  (t.sh|t)
    set -o nounset -o errexit
    t "$@"
    ;;
esac
