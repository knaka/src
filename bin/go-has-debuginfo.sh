#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b0b996c-false}" && return 0; sourced_b0b996c=true

# file(1) of MacOS does not show whether the executable contains Go debuginfo or not.
# dwarfdump(1) shows nothing. I do not know why.

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/commands.sh
shift 2
cd "$1" || exit 1; shift

show_help_2269cee() {
  cat <<EOF
Succeeds if the binary has Go debug info.

Usage: $0 <executable_file>
EOF
}

go_has_debuginfo() {
  test "$#" -lt 1 && show_help_2269cee && return 1
  init_temp_dir
  file="$TEMP_DIR/06454c6"
  go tool objdump -s main.main "$1" | tee "$file" >&2
  if test -s "$file"
  then
    go tool objdump -s waitSTDIN "$1" >"$file"
    if test -s "$file"
    then
      echo "The binary provides \"initwait\" feature." >&2
    else
      echo "The binary DOES NOT provide \"initwait\" feature. To enable it, you should include \"initwait\" code and add \"-tags debug\" flag to compile." >&2
    fi
    return 0
  fi
  echo "The binary does not contain debug info. You should build the binary with \"go ... -gcflags='all=-N -l' ...\" flag and not run strip(1)." >&2
  return 1
}

case "${0##*/}" in
  (go-has-debuginfo.sh|go-has-debuginfo)
    set -o nounset -o errexit
    go_has_debuginfo "$@"
    ;;
esac
