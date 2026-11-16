# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_DATETIME_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# [RFC 3339 vs ISO 8601](https://ijmacd.github.io/rfc3339-iso8601/)

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

iso_datetime_format_590c473='%Y-%m-%dT%H:%M:%S%z'
iso_datetime_format_utc_590c473='%Y-%m-%dT%H:%M:%SZ'

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
    date -j +"$iso_datetime_format_590c473"
  else
    date +"$iso_datetime_format_590c473"
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
    if ! epoch="$(date -j -f "$iso_datetime_format_590c473" "$iso_date" +%s 2>/dev/null)"
    then
      epoch="$(TZ=UTC0 date -j -f "$iso_datetime_format_utc_590c473" "$iso_date" +%s)"
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
    date -j -r "$epoch" +"$iso_datetime_format_590c473"
  else
    date -d @"$epoch" +"$iso_datetime_format_590c473"
  fi
}

# Touch files, setting their modification time to the given ISO-8601 time.
# Usage: touch_iso --mtime=<ISO_time> <file>...
# Example: touch_iso --mtime=2024-01-01T12:00:00Z file.txt
touch_iso() {
  local mtime=
  OPTIND=1; while getopts _-:d: OPT
  do
    test "$OPT" = - && OPT="${OPTARG%%=*}" && OPTARG="${OPTARG#"$OPT"=}"
    case "$OPT" in
      (d|mtime) mtime="$OPTARG";;
      (?) return 1;;
      (*) echo "$0: illegal option -- $OPT" >&2; return 1;;
    esac
  done
  shift $((OPTIND-1))

  if test -z "$mtime"
  then
    echo "Usage: ${0##*[/\\]} --mtime=<ISO_time> <file>..." >&2
    return 1
  fi
  if is_bbwin
  then
    # BusyBox date(1) does not seem to handle "%z". Use PowerShell to do this.
    local file
    for file in "$@"
    do
      pwsh.exe -NoProfile -Command "Set-ItemProperty \"$file\" -Name LastWriteTime -Value \"$mtime\""
    done
    return
  fi
  if is_macos
  then
    # BSD touch(1) does not accept ISO time with timezone. Convert to UTC.
    local time_utc
    if time_utc="$(TZ=UTC0 date -j -f "$iso_datetime_format_590c473" "$mtime" +"$iso_datetime_format_utc_590c473" 2>/dev/null)"
    then
      mtime="${time_utc}"
    fi
  fi
  touch -d "$mtime" "$@"
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
    stat -f "%Sm" -t "$iso_datetime_format_590c473" "$file"
  elif is_bbwin
  then
    local epoch
    epoch="$(stat -c "%Y" "$file")"
    date -d @"$epoch" -Iseconds | sed -E -e 's/([[:digit:]]{2}):([[:digit:]]{2})$/\1\2/'
  else
    date --date "$(stat --format "%y" "$file")" +"$iso_datetime_format_590c473"
  fi
}

# ==========================================================================
#region Extract ISO datetime components.

result_b20e134=

iso_datetime_year_25dd9ce() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime%%-*}"
}

iso_datetime_year_() {
  iso_datetime_year_25dd9ce "$@"
  set_ "$result_b20e134"
}

iso_datetime_year() {
  iso_datetime_year_25dd9ce "$@"
  printf "%s\n" "$result_b20e134"
}

iso_datetime_month_ec3e4f1() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*-}"
  result_b20e134="${result_b20e134%%-*}"
}

iso_datetime_month_() {
  iso_datetime_month_ec3e4f1 "$@"
  set_ "$result_b20e134"
}

iso_datetime_month() {
  iso_datetime_month_ec3e4f1 "$@"
  printf "%s\n" "$result_b20e134"
}

iso_datetime_day_bc6befe() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*-}"
  result_b20e134="${result_b20e134#*-}"
  result_b20e134="${result_b20e134%%T*}"
}

iso_datetime_day_() {
  iso_datetime_day_bc6befe "$@"
  set_ "$result_b20e134"
}

iso_datetime_day() {
  iso_datetime_day_bc6befe "$@"
  printf "%s\n" "$result_b20e134"
}

iso_datetime_hour_2d32609() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134%%:*}"
}

iso_datetime_hour_() {
  iso_datetime_hour_2d32609 "$@"
  set_ "$result_b20e134"
}

iso_datetime_hour() {
  iso_datetime_hour_2d32609 "$@"
  printf "%s\n" "$result_b20e134"
}

iso_datetime_minute_cbdb6d5() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134#*:}"
  result_b20e134="${result_b20e134%%:*}"
}

iso_datetime_minute_() {
  iso_datetime_minute_cbdb6d5 "$@"
  set_ "$result_b20e134"
}

iso_datetime_minute() {
  iso_datetime_minute_cbdb6d5 "$@"
  printf "%s\n" "$result_b20e134"
}

iso_datetime_second_a08d944() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134#*:}"
  result_b20e134="${result_b20e134#*:}"
  # Drop what follows the digits, such as the fraction of a second and the time zone ("Z" or "+0900").
  result_b20e134="${result_b20e134%%[!0-9]*}"
}

iso_datetime_second_() {
  iso_datetime_second_a08d944 "$@"
  set_ "$result_b20e134"
}

iso_datetime_second() {
  iso_datetime_second_a08d944 "$@"
  printf "%s\n" "$result_b20e134"
}

#endregion

# ==========================================================================
#region Convert ISO datetime.

# Convert the ISO datetime to UTC only with the shell arithmetic, without the extensions of date(1), which differ among platforms. The time zone must be given as "Z", "+0900", "+09:00" or "+09", since a local time cannot be converted without the time zone database. The fraction of a second is dropped.
iso_datetime_to_utc_827ddcc() {
  local iso_datetime="$1"
  local year month day hour minute second
  iso_datetime_year_25dd9ce "$iso_datetime"; year="$result_b20e134"
  iso_datetime_month_ec3e4f1 "$iso_datetime"; month="$result_b20e134"
  iso_datetime_day_bc6befe "$iso_datetime"; day="$result_b20e134"
  iso_datetime_hour_2d32609 "$iso_datetime"; hour="$result_b20e134"
  iso_datetime_minute_cbdb6d5 "$iso_datetime"; minute="$result_b20e134"
  iso_datetime_second_a08d944 "$iso_datetime"; second="$result_b20e134"
  # Prefix "1" and subtract it back, since a number with a leading zero, such as "08", is regarded as octal.
  year=$((1$year - 10000))
  month=$((1$month - 100))
  day=$((1$day - 100))
  hour=$((1$hour - 100))
  minute=$((1$minute - 100))
  second=$((1$second - 100))

  # The time zone is what follows the time, starting with "Z", "+" or "-".
  local zone="${iso_datetime#*T}"
  zone="${zone#"${zone%%[Zz+-]*}"}"
  local offset=0
  case "$zone" in
    ([Zz]) ;;
    ([+-][0-9][0-9]*)
      local zone_hour zone_minute
      zone_hour="${zone#?}"
      zone_minute="${zone_hour#??}"
      zone_hour="${zone_hour%"$zone_minute"}"
      zone_minute="${zone_minute#:}"
      offset=$(((1$zone_hour - 100) * 3600 + (1${zone_minute:-00} - 100) * 60))
      test "${zone%"${zone#?}"}" = - && offset=$((-offset))
      ;;
    (*)
      echo "No time zone in \"$iso_datetime\"." >&2
      return 1
      ;;
  esac

  # Count the days since the epoch. The year is regarded as starting in March, so that the leap day comes at the end of it.
  # [chrono-Compatible Low-Level Date Algorithms](https://howardhinnant.github.io/date_algorithms.html#days_from_civil)
  local y=$((year - (month <= 2)))
  local era=$(((y >= 0 ? y : y - 399) / 400))
  local yoe=$((y - era * 400))
  local doy=$(((153 * (month + (month > 2 ? -3 : 9)) + 2) / 5 + day - 1))
  local doe=$((yoe * 365 + yoe / 4 - yoe / 100 + doy))
  local days=$((era * 146097 + doe - 719468))

  local seconds=$((days * 86400 + hour * 3600 + minute * 60 + second - offset))
  # Floor the division, which truncates toward zero, for the times before the epoch.
  days=$(((seconds - (seconds < 0 ? 86399 : 0)) / 86400))
  seconds=$((seconds - days * 86400))

  # Convert the days back to the date in the same way.
  # [chrono-Compatible Low-Level Date Algorithms](https://howardhinnant.github.io/date_algorithms.html#civil_from_days)
  days=$((days + 719468))
  era=$(((days >= 0 ? days : days - 146096) / 146097))
  doe=$((days - era * 146097))
  yoe=$(((doe - doe / 1460 + doe / 36524 - doe / 146096) / 365))
  doy=$((doe - (365 * yoe + yoe / 4 - yoe / 100)))
  local mp=$(((5 * doy + 2) / 153))
  day=$((doy - (153 * mp + 2) / 5 + 1))
  month=$((mp + (mp < 10 ? 3 : -9)))
  year=$((yoe + era * 400 + (month <= 2)))

  printf_v result_b20e134 "%04d-%02d-%02dT%02d:%02d:%02dZ" "$year" "$month" "$day" \
    $((seconds / 3600)) $((seconds % 3600 / 60)) $((seconds % 60))
}

iso_datetime_to_utc_() {
  iso_datetime_to_utc_827ddcc "$@" || return $?
  set_ "$result_b20e134"
}

# Convert the ISO datetime with a time zone to UTC.
# Usage: iso_datetime_to_utc <ISO_datetime>
# Example: iso_datetime_to_utc 2025-01-01T09:00:00+0900  # => 2025-01-01T00:00:00Z
iso_datetime_to_utc() {
  iso_datetime_to_utc_827ddcc "$@" || return $?
  printf "%s\n" "$result_b20e134"
}

#endregion
