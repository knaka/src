# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ _LIB_TIME_SH && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

# https://ijmacd.github.io/rfc3339-iso8601/

iso_date_format_590c473='%Y-%m-%dT%H:%M:%S%z'
iso_date_format_utc_590c473='%Y-%m-%dT%H:%M:%SZ'

# Output current date and time in ISO-8601 format.
# Usage: date_iso
# Example: date_iso  # => 2024-01-01T12:00:00+0900
date_iso() {
  if is_bbwin
  then
    # -I[SPEC]: Output ISO-8601 date / SPEC=date (default), hours, minutes, seconds or ns
    date -Iseconds | sed -E -e 's/([[:digit:]]{2}):([[:digit:]]{2})$/\1\2/'
  elif is_macos
  then
    # -j: Do not try to set the dates
    date -j +"$iso_date_format_590c473"
  else
    date +"$iso_date_format_590c473"
  fi
}

# Convert an ISO-8601 date string to UNIX epoch seconds.
# Usage: iso_to_epoch <ISO_time>
# Example: iso_to_epoch 2024-01-01T12:00:00+0900  # => 1704078000
iso_to_epoch() {
  local iso_date="$1"
  if is_macos
  then
    local epoch
    if ! epoch="$(date -j -f "$iso_date_format_590c473" "$iso_date" +%s 2>/dev/null)"
    then
      epoch="$(TZ=UTC0 date -j -f "$iso_date_format_utc_590c473" "$iso_date" +%s)"
    fi
    echo "$epoch"
  elif is_windows
  then
    pwsh.exe -NoProfile -Command "Get-Date \"$iso_date\" -UFormat %s"
  else
    date -d "$iso_date" +%s
  fi
}

# Convert UNIX epoch seconds to an ISO-8601 date string.
# Usage: epoch_to_iso <epoch>
# Example: epoch_to_iso 1704078000  # => 2024-01-01T12:00:00+0900
epoch_to_iso() {
  local epoch="$1"
  if is_macos
  then
    date -j -r "$epoch" +"$iso_date_format_590c473"
  else
    date -d @"$epoch" +"$iso_date_format_590c473"
  fi
}

# Touch files, setting their modification time to the given ISO-8601 time.
# Usage: touch_time_iso --mtime=<ISO_time> <file>...
# Example: touch_time_iso --mtime=2024-01-01T12:00:00Z file.txt
touch_time_iso() {
  local time=
  OPTIND=1; while getopts _-:d: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (d|mtime) time="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -z "$time"
  then
    touch "$@" || return $?
    return
  fi
  if is_bbwin
  then
    # BusyBox date(1) does not seem to handle "%z". Use PowerShell to do this.
    local file
    for file in "$@"
    do
      pwsh.exe -NoProfile -Command "Set-ItemProperty \"$file\" -Name LastWriteTime -Value \"$time\""
    done
    return
  fi
  if is_macos
  then
    # BSD touch(1) does not accept ISO time with timezone. Convert to UTC.
    local time_utc
    if time_utc="$(TZ=UTC0 date -j -f "$iso_date_format_590c473" "$time" +"$iso_date_format_utc_590c473" 2>/dev/null)"
    then
      time="${time_utc}"
    fi
  fi
  touch -d "$time" "$@"
}

# Output last modification time of a file in ISO-8601 format.
# Usage: last_mod_iso <file>
# Example: last_mod_iso file.txt  # => 2024-01-01T12:00:00+0900
last_mod_iso() {
  local file="$1"
  if is_macos
  then
    # S: String
    # a, m, c, B: Last accessed or modified, or when the inode was last changed, or the birth time of the inode
    stat -f "%Sm" -t "$iso_date_format_590c473" "$file"
  elif is_bbwin
  then
    local epoch
    epoch="$(stat -c "%Y" "$file")"
    date -d @"$epoch" -Iseconds | sed -E -e 's/([[:digit:]]{2}):([[:digit:]]{2})$/\1\2/'
  else
    date --date "$(stat --format "%y" "$file")" +"$iso_date_format_590c473"
  fi
}
