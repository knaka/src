#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b7ccc35-false}" && return 0; sourced_b7ccc35=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/commands.lib.sh
shift 2
cd "$1" || exit 1; shift 2

export GHQ_ROOT="$HOME"/repos

# `ghq list` takes too long to walk recursively. Instead, return paths of Git repositories found within a few levels of depth from $GHQ_ROOT.
ghq_list() {
  find \
    "$GHQ_ROOT"/*/.git \
    "$GHQ_ROOT"/*/*/.git \
    "$GHQ_ROOT"/*/*/*/.git \
    -type d \
    -maxdepth 0 2>/dev/null \
  | while read -r p
    do
      test -d "$p" || continue
      p="${p%/.git}"
      p="${p#"$GHQ_ROOT"}"
      p="${p#/}"
      echo "$p"
    done
}

repo() {
  local prefix=
  if test "${1+set}" = "set"
  then
    case "$1" in
      (get|clone|list|rm|root|create|help|h)
        ghq "$@"
        return $?
        ;;
      (*)
        prefix="$1"
        ;;
    esac
  fi
  # If no ghq-subcommand is specified, show the list of repos.
  local IFS="$newline_char"
  # shellcheck disable=SC2046
  set -- $(ghq_list)
  if test -n "$prefix"
  then
    local IFS="$newline_char"
    # shellcheck disable=SC2046
    set -- $(printf "%s\n" "$@" | grep -E -e "\b$prefix")
    if test $# -eq 0
    then
      echo "No matching entry for '$prefix'." >&2
      return 1
    fi
  fi
  test $# -eq 0 && return 1
  if test $# -ge 2
  then
    set -- "$(printf "%s\n" "$@" | gum filter)"
  fi
  test -z "$1" && return 1
  echo "$GHQ_ROOT"/"$1"
}

case "${0##*/}" in
  (r.sh|r|repo.sh|repo)
    set -o nounset -o errexit
    repo "$@"
    ;;
esac
