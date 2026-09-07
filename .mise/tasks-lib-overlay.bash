#!/usr/bin/env bash
set -- _2086c80 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

readonly REPOS="$HOME"/repos
readonly REPO_OVERLAY="$REPOS"/github.com/$USER/repo-overlay

run_chezmoi() {
  local source_dir="$REPO_OVERLAY"/"${PROJECT_DIR#"$REPOS/"}"
  local dest_dir="$PROJECT_DIR"
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (source) source_dir="$OPTARG";;
      (destination) dest_dir="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  chezmoi --source="$source_dir" --destination="$dest_dir" "$@"
}

# Generate the Git exclude configuration for the overlaid files.
task_overlay__exclude__gen() {
  local dest_dir="$PROJECT_DIR"
  run_chezmoi managed \
  | while read -r file_path
    do
      if test -d "$dest_dir/$file_path"
      then
        echo Skipping "$file_path" >&2
        continue
      fi
      echo "/$file_path"
    done \
  >"$dest_dir"/.git/info/exclude
}

# [files...] Add overlaid files. If no file is specified, re-add managed files.
task_overlay__add() {
  if test $# -eq 0
  then
    run_chezmoi re-add
    return 0
  fi
  run_chezmoi add "$@"
  task_overlay__exclude__gen
}

# Show diff for managed overlaid files.
task_overlay__diff() {
  run_chezmoi diff --reverse
}

# Show managed overlaid files.
task_overlay__managed() {
  run_chezmoi managed --include=files,symlinks
}

# Remove overlaid targets from the source state.
task_overlay__forget() {
  run_chezmoi forget "$@"
  task_overlay__exclude__gen
}
