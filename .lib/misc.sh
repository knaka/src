#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_MISC_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

result_712a8b2=

cmdbase_snake_f48cb94() {
  result_712a8b2=
  local s="$1"
  s="${s##*[/\\]}"
  s="${s%.sh}"
  s="${s%.bash}"
  local left
  while test -n "$s"
  do
    left=${s%%-*}
    test "$left" = "$s" && result_712a8b2="$result_712a8b2$s" && return
    result_712a8b2="$result_712a8b2$left"_
    s="${s#*-}"
  done
}

# Convert the path of a command to the base name in snake case, without the directory, the extension ".sh" or ".bash", and with hyphens replaced with underscores, such as "/path/to/some-name.sh" to "some_name". Print it, or assign it to the variable given with "-v var".
# Usage: cmdbase_snake [-v var] path
cmdbase_snake() {
  local var_name_1b43ce8=
  test "${1-}" = "-v" && var_name_1b43ce8="$2" && shift 2
  cmdbase_snake_f48cb94 "$@"
  print_to "$var_name_1b43ce8" "$result_712a8b2"
}

# Check if a directory is empty.
is_dir_empty() {
  test -d "$1" || return 1
  ! test -e "$1"/* 2>/dev/null
}

# [<file>] Read the file and print substituting environment variables. Unlike envsubst(1), this tries to expand undefined environment variables and fails for that.
env_subst() {
  if test "$#" -gt 0
  then
    local template_file="$1"
    eval "cat <<EOF
$(cat "$template_file")
EOF"
  else
    eval "cat <<EOF
$(cat)
EOF"
  fi
}

# [regex replacement ...] Substitute text that matches regex patterns in stdin input. Takes pairs of regex/replacement arguments and applies them via sed(1).
resubst() {
  local step=2
  local i=0 n=$(($# / step))
  while test "$i" -lt "$n"
  do
    set -- "$@" -e "s${CH_US}$1${CH_US}$2${CH_US}g"
    shift $step
    i=$((i + 1))
  done
  sed "$@"
}

filter_log() {
  awk '{printf "\r%s\n", $0}'
}

# Create a file from the standard input if it does not exist.
ensure_file() {
  local file_path="$1"
  if test -f "$file_path"
  then
    echo "File $file_path already exists. Skipping creation." >&2
    return 0
  fi
  echo "Creating file $file_path." >&2
  mkdir -p "$(dirname "$file_path")"
  cat >"$file_path"
}
