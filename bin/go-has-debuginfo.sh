#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_GO_HAS_DEBUGINFO_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

# file(1) of MacOS does not show whether the executable contains Go debuginfo or not.
# dwarfdump(1) shows nothing. I do not know why.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/commands.sh
cd "$3" || exit; shift 3 # /shpp:sources

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

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (go-has-debuginfo.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  go_has_debuginfo "$@"
fi
