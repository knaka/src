#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ b1dae46 && return 0

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

is_mise_project_dir() {
  local dir=.
  test $# -gt 0 && dir="$1"
  # 6 files, 1 dir // Configuration | mise-en-place https://mise.jdx.dev/configuration.html
  # 5 dirs // File Tasks | mise-en-place https://mise.jdx.dev/tasks/file-tasks.html
     test -r "$dir"/mise.local.toml \
  || test -r "$dir"/mise.toml \
  || test -r "$dir"/mise/config.toml \
  || test -r "$dir"/.mise/config.toml \
  || test -r "$dir"/.config/mise.toml \
  || test -r "$dir"/.config/mise/config.toml \
  || test -d "$dir"/.config/mise/conf.d \
  || test -d "$dir"/mise-tasks \
  || test -d "$dir"/mise/tasks \
  || test -d "$dir"/.mise-tasks \
  || test -d "$dir"/.mise/tasks \
  || test -d "$dir"/.config/mise/tasks \
  #nop
}

t() {
  # Marker
  is_windows && export executed_thru_t_bb789ec=true
  local original_pwd="$PWD"
  while :
  do
    if is_mise_project_dir
    then
      if test -x ./task
      then
        set -- "$PWD"/task "$@"
      else
        if test $# -gt 0
        then
          set -- run "$@"
        else
          set -- tasks
        fi
        if test -x ./mise
        then
          set -- "$PWD"/mise "$@"
        else
          set -- mise "$@"
        fi
      fi
      cd "$original_pwd" || return 1
      exec "$@"
      return $?
    fi
    cd ..
    if test "$PWD" = "$OLDPWD"
    then
      echo Reached to the root dir. >&2
      return 1
    fi
  done
}

case ",${0##*/},${0##*\\}," in
  (*,t.sh,*|*,t,*)
    set -o nounset -o errexit
    t "$@"
    ;;
esac
