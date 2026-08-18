#!/usr/bin/env sh
set -- _52850b5 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null && set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit && shift 3 # /shpp:sources

if is_windows
then
  for path in "$@"
  do
    if ! test -e "$path"
    then
      echo "No such file or directory: $path" >&2
      continue
    fi
    path="$(realpath "$path")"
    ifs_pipe
    for attrib in ${PSV_FILE_SHARING_IGNORANCE_ATTRIBUTES-}
    do
      # Remove trailing backslashes.
      printf "%s:%s " "$path" "$attrib":
      if PowerShell.exe -Command "Get-Content $path:$attrib" > /dev/null 2>&1
      then
        PowerShell.exe -Command "Get-Content $path:$attrib"
      else
        echo "-"
      fi
    done
    ifs_restore
  done
  exit 0
fi

if type xattr > /dev/null 2>&1
then
  xattr "$@"
  exit 0
elif type getfattr > /dev/null 2>&1
then
  getfattr -d -m - "$@"
  exit 0
else
  echo "No extended attributes support." >&2
  exit 1
fi
