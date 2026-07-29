#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_GC_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

gc() {
  if test "${SSH_CONNECTION+set}" = set # ?
  then
    local reader_port="${READER_PORT-10002}"
    nc -q0 127.0.0.1 "$reader_port" </dev/null
  elif test -d \\ # Windows
  then
    # `Get-Clipboard` appends a trailing newline. I do not know why, — What is the easiest way to remove 1st and last line from file with awk? - Stack Overflow https://stackoverflow.com/questions/15856733/what-is-the-easiest-way-to-remove-1st-and-last-line-from-file-with-awk
    # shellcheck disable=SC2016
    pwsh.exe -NoProfile -command '(Get-Clipboard -Raw).TrimEnd("`r`n")' | tr -d '\r'
  elif command -v pbpaste > /dev/null 2>&1 # macOS
  then
    pbpaste
  elif command -v xclip > /dev/null 2>&1 # Linux
  then
    # astrand/xclip: Command line interface to the X11 clipboard https://github.com/astrand/xclip
    xclip -selection clipboard -o
  elif command -v xsel > /dev/null 2>&1 # Linux
  then
    # kfish/xsel: A command-line program for getting and setting the contents of the X selection https://github.com/kfish/xsel
    xsel --clipboard --output
  # elif command -v xclipboard
  # then
  #   xclipboard ?
  else
    echo "No clipboard utility found." >&2
    exit 1
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (gc.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  gc "$@"
fi
