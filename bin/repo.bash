#!/usr/bin/env bash
set -- _BIN_REPO_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/commands.sh
popd >/dev/null || exit

export GHQ_ROOT="$HOME"/repos

# `ghq list` takes too long because it walks recursively all the way down to the deepest files. Instead, return paths of Git repositories found within a few levels of depth from $GHQ_ROOT.
ghq_list() {
  find "$GHQ_ROOT" \
    -mindepth 2 \
    -maxdepth 4 \
    -type d \
    -name ".git" \
  2>/dev/null \
  | while read -r p
    do
      p="${p%/.git}"
      p="${p#"$GHQ_ROOT"}"
      p="${p#/}"
      echo "$p"
    done
}

repo() {
  local prefix=
  if test "${1+set}"
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
  # If neither a ghq-subcommand nor a repository name (or its prefix) is specified, show the list of repos.
  local -a repos
  while read -r; do repos+=("$REPLY"); done < <(ghq_list)
  if test -n "$prefix"
  then
    while :
    do
      local -a matched
      while read -r; do matched+=("$REPLY"); done \
      < <(printf "%s\n" "${repos[@]}" | grep -E -e "/$prefix")
      if test "${#matched[@]}" -eq 0
      then
        echo "No matching entry for '$prefix'." >&2
        return 1
      fi
      repos=("${matched[@]}")
      break
    done
  fi
  if test "${#repos[@]}" -eq 0
  then
    echo "No entry." >&2
    return 1
  fi
  local selected="${repos[0]}"
  if test "${#repos[@]}" -gt 1
  then
    selected=$(printf "%s\n" "${repos[@]}" | gum filter)
  fi
  test -z "$selected" && return 1
  echo "$GHQ_ROOT"/"$selected"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  repo "$@"
fi
