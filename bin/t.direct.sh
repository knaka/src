#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_T_DIRECT_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

is_mise_project_dir() {
  local dir=.
  test $# -gt 0 && dir="$1"

  # 6 files, 1 dir // Configuration | mise-en-place https://mise.jdx.dev/configuration.html
  test -r "$dir"/mise.local.toml && return 0
  test -r "$dir"/mise.toml && return 0
  test -r "$dir"/mise/config.toml && return 0
  test -r "$dir"/.mise/config.toml && return 0
  test -r "$dir"/.config/mise.toml && return 0
  test -r "$dir"/.config/mise/config.toml && return 0
  test -d "$dir"/.config/mise/conf.d && return 0

  # 5 dirs // File Tasks | mise-en-place https://mise.jdx.dev/tasks/file-tasks.html
  test -d "$dir"/mise-tasks && return 0
  test -d "$dir"/mise/tasks && return 0
  test -d "$dir"/.mise-tasks && return 0
  test -d "$dir"/.mise/tasks && return 0
  test -d "$dir"/.config/mise/tasks && return 0

  return 1
}

t() {
  # Marker
  is_windows && export executed_thru_t_bb789ec=true
  local original_pwd="$PWD"
  while :
  do
    if is_mise_project_dir "$PWD"
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

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (t.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  t "$@"
fi
