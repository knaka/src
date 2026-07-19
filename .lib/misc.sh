#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 35360ac && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit; shift

cmdbase_snake_() {
  RESULT=
  local s="$1"
  s="${s##*[/\\]}"
  s="${s%.sh}"
  s="${s%.bash}"
  local left
  while test -n "$s"
  do
    left=${s%%-*}
    test "$left" = "$s" && RESULT="$RESULT$s" && return
    RESULT="$RESULT$left"_
    s="${s#*-}"
  done
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
    set -- "$@" -e "s${ch_us}$1${ch_us}$2${ch_us}g"
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
