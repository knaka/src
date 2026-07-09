#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 4a95975 && return 0

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
cd "$1" || exit 1; shift

# Current cache file path for memoization.
cache_file_path_cb3727b=

begin_memoize() {
  cache_file_path_cb3727b="$TEMP_DIR"/cache-"$(echo "$@" | sha1sum | cut -d' ' -f1)"
  if test -r "$cache_file_path_cb3727b"
  then
    cat "$cache_file_path_cb3727b"
    return 1
  fi
  exec 9>&1
  exec >"$cache_file_path_cb3727b"
}

end_memoize() {
  exec 1>&9
  exec 9>&-
  cat "$cache_file_path_cb3727b"
}
