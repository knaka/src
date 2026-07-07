# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 3100e42 && return 0

gc() {
  if test "${SSH_CONNECTION+set}" = set
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
    xclip -selection clipboard -o
  elif command -v xsel > /dev/null 2>&1 # Linux
  then
    xsel --clipboard --output
  else
    echo "No clipboard utility found." >&2
    exit 1
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  gc "$@"
fi
