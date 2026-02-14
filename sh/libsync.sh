# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_14437a3-false}" && return 0; sourced_14437a3=true

# libsync - Library synchronization tool
#
# Manage external library files using git sparse checkout.
# Tracks fetched files and their source commits in .libsync.json.
#
# Usage:
#   libsync add <name> <repo> <path>...     Add a library (sparse checkout)
#     --branch=<branch>                       Branch to checkout (default: main)
#     --dest=<dir>                            Destination directory (default: .)
#   libsync pull <name>                     Update a library to latest commit
#   libsync diff <name>                     Show local changes vs fetched version
#   libsync add-path <name> <path>...       Add paths to a library (config only)
#   libsync remove-path <name> <path>...    Remove paths from a library (config only)

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
. ./.lib/time.lib.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

CONFIG_FILE=".libsync.json"

get_lib_info() {
  local name="$1"
  local entry
  entry="$(
    jq --exit-status --arg name "$name" '.libraries[] | select(.name == $name)' \
    <"$CONFIG_FILE"
  )" || {
    echo "Error: library \"$name\" not found." >&2
    return 1
  }
  repo="$(printf '%s' "$entry" | jq -r '.repo')"
  branch="$(printf '%s' "$entry" | jq -r '.branch')"
  dest="$(printf '%s' "$entry" | jq -r '.dest')"
  paths_json="$(printf '%s' "$entry" | jq '.paths')"
  commit="$(printf '%s' "$entry" | jq -r '.commit')"
}

cmd_clone() {
  local repo
  local branch="main"
  local dest="."
  local paths_json
  local commit

  local pull=false
  OPTIND=1; while getopts _-: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (branch) branch="$OPTARG";;
      (dest) dest="$OPTARG";;
      (pull) pull=true;;
      (*) echo "Unexpected option: $OPT" >&2; exit 1;;
    esac
  done
  shift $((OPTIND-1))

  local name="$1"
  shift

  if "$pull"
  then
    # Pull mode: read config from JSON
    get_lib_info "$name"
    # Convert JSON array to positional parameters
    local IFS="$newline_char"
    # shellcheck disable=SC2046
    set -- $(printf '%s' "$paths_json" | jq -r '.[]')
  else
    # Clone mode: use command line arguments
    repo="$1"
    shift
    # Check if already exists
    if jq --exit-status --arg name "$name" '.libraries[] | select(.name == $name)' <"$CONFIG_FILE" >/dev/null 2>&1
    then
      echo "Error: library \"$name\" already exists." >&2
      return 1
    fi
    paths_json="$(printf '%s\n' "$@" | jq --raw-input . | jq --slurp .)"
  fi

  local dest_path
  dest_path="$(canon_path "$dest")"

  # Clone with sparse checkout
  work_dir="$TEMP_DIR"/work-$$
  git clone --filter=blob:none --sparse "$repo" "$work_dir"
  push_dir "$work_dir"

  # Set sparse-checkout patterns
  local IFS="$newline_char"
  # shellcheck disable=SC2046
  git sparse-checkout set --no-cone $(printf "/%s\n" "$@")

  local commit timestamp
  commit="$(git rev-parse HEAD)"
  timestamp="$(date_iso)"

  # Copy files
  mkdir -p "$dest_path"
  for pattern in "$@"
  do
    find . -path "./$pattern" -print0 \
    | tar --null -T - -cf - \
    | tar --cd "$dest_path" -xf -
  done

  pop_dir

  # Record/update metadata
  if "$pull"
  then
    # Update existing entry
    jq \
      --arg name "$name" \
      --arg commit "$commit" \
      --arg fetched_at "$timestamp" \
      '
        (.libraries[] | select(.name == $name)) |= . + {
          commit: $commit,
          fetched_at: $fetched_at
        }
      ' "$CONFIG_FILE" \
      > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Updated $name (commit: $(echo "$commit" | sed -E -e 's/^(.......).*/\1/'))"
  else
    # Add new entry
    local new_entry
    new_entry="$(jq -n \
      --arg name "$name" \
      --arg repo "$repo" \
      --argjson paths "$paths_json" \
      --arg dest "$dest" \
      --arg branch "$branch" \
      --arg commit "$commit" \
      --arg fetched_at "$timestamp" \
      '
        {
          name: $name,
          repo: $repo,
          paths: $paths,
          dest: $dest,
          branch: $branch,
          commit: $commit,
          fetched_at: $fetched_at
        }
      '
    )"
    jq --argjson entry "$new_entry" '.libraries += [$entry]' "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Added $name (commit: $(echo "$commit" | sed -E -e 's/^(.......).*/\1/'))"
  fi

  rm -rf "$work_dir"
}

cmd_diff() {
  local repo
  local branch="main"
  local dest="."
  local paths_json
  local commit

  local name="$1"
  get_lib_info "$name"

  # Convert JSON array to positional parameters
  local IFS="$newline_char"
  # shellcheck disable=SC2046
  set -- $(printf '%s' "$paths_json" | jq -r '.[]')

  local dest_path
  dest_path="$(canon_path "$dest")"

  # Copy local files to temp directory
  local local_dir="$TEMP_DIR"/local-$$
  mkdir -p "$local_dir"
  push_dir "$dest_path"
  for pattern in "$@"
  do
    find . -path "./$pattern" -print0 \
    | tar --null -T - -cf - \
    | tar --cd "$local_dir" -xf -
  done
  pop_dir

  # Clone and checkout the recorded commit
  local orig_dir="$TEMP_DIR"/orig-$$
  git clone --filter=blob:none --sparse "$repo" "$orig_dir"
  push_dir "$orig_dir"
  git checkout "$commit"
  # shellcheck disable=SC2046
  git sparse-checkout set --no-cone $(printf "/%s\n" "$@")
  pop_dir

  # Generate diff (original -> local) for each path
  for pattern in "$@"
  do
    diff -uN "$orig_dir/$pattern" "$local_dir/$pattern" || true
  done

  rm -rf "$local_dir" "$orig_dir"
}

cmd_add_path() {
  local name="$1"
  shift

  # Check if library exists
  if ! jq --exit-status --arg name "$name" '.libraries[] | select(.name == $name)' <"$CONFIG_FILE" >/dev/null 2>&1
  then
    echo "Error: library \"$name\" not found." >&2
    return 1
  fi

  # Add paths to the library
  local paths_to_add
  paths_to_add="$(printf '%s\n' "$@" | jq --raw-input . | jq --slurp .)"
  jq --arg name "$name" --argjson paths "$paths_to_add" \
    '(.libraries[] | select(.name == $name) | .paths) += $paths | .libraries[] |= (.paths |= unique)' \
    "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
  mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  echo "Added paths to $name: $*"
}

cmd_remove_path() {
  local name="$1"
  shift

  # Check if library exists
  if ! jq --exit-status --arg name "$name" '.libraries[] | select(.name == $name)' <"$CONFIG_FILE" >/dev/null 2>&1
  then
    echo "Error: library \"$name\" not found." >&2
    return 1
  fi

  # Remove paths from the library
  local paths_to_remove
  paths_to_remove="$(printf '%s\n' "$@" | jq --raw-input . | jq --slurp .)"
  jq --arg name "$name" --argjson paths "$paths_to_remove" \
    '(.libraries[] | select(.name == $name) | .paths) -= $paths' \
    "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
  mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  echo "Removed paths from $name: $*"
}

libsync() {
  register_temp_cleanup
  if ! test -f "$CONFIG_FILE"
  then
    jq -n '{}' >"$CONFIG_FILE"
  fi
  test $# = 0 && set --
  case "$1" in
    (add|clone) shift; cmd_clone "$@";;
    (update|pull) shift; cmd_clone --pull "$@";;
    (diff) shift; cmd_diff "$@";;
    (add-path) shift; cmd_add_path "$@";;
    (remove-path) shift; cmd_remove_path "$@";;
    (*) echo "Usage: libsync {add|pull|diff|add-path|remove-path}" ;;
  esac
}

case "${0##*/}" in
  (libsync.sh|libsync)
  set -o nounset -o errexit
  libsync "$@"
  ;;
esac
