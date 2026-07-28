#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ BIN_REPO_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@" # shpp:begin_source
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # shpp:end_source

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
  local IFS="$CH_LF"
  # shellcheck disable=SC2046
  set -- $(ghq_list)
  if test -n "$prefix"
  then
    local IFS="$CH_LF"
    while :
    do
      # Exact match
      if printf "%s\n" "$@" | grep -E -e "/$prefix$" >/dev/null 2>&1
      then
        # shellcheck disable=SC2046
        set -- $(printf "%s\n" "$@" | grep -E -e "/$prefix$")
        break
      fi
      # Match by prefix
      # shellcheck disable=SC2046
      set -- $(printf "%s\n" "$@" | grep -E -e "/$prefix")
      if test $# -eq 0
      then
        echo "No matching entry for '$prefix'." >&2
        return 1
      fi
      break
    done
  fi
  test $# -eq 0 && return 1
  if test $# -ge 2
  then
    set -- "$(printf "%s\n" "$@" | gum filter)"
  fi
  test -z "$1" && return 1
  echo "$GHQ_ROOT"/"$1"
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case ".${0##*[/\\]}." in (*.repo.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  repo "$@"
fi
