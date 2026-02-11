#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_b8dd816-false}" && return 0; sourced_b8dd816=true

# file(1) of MacOS does not show whether the executable contains Go debuginfo or not.
# dwarfdump(1) shows nothing. I do not know why.

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
set -- _LIBDIR .lib "$@"
. ./.lib/task.sh
. ./.lib/tools.lib.sh
shift 2
cd "$1" || exit 1; shift 2

show_help_2269cee() {
  cat <<EOF
Succeeds if the binary has Go debug info.

Usage: $0 <executable_file>
EOF
}

go_has_debuginfo() {
  test "$#" -lt 1 && show_help_2269cee && return 1
  register_temp_cleanup
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
