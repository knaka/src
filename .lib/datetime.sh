# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_DATETIME_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# The ISO datetime strings handled here are of the ISO 8601 extended format, with the date and the time joined by "T" and a time zone always given, as RFC 3339 requires:
#   Input:  YYYY-MM-DDThh:mm:ss[.fraction](Z|+hh:mm|+hhmm|+hh), where "+" may be "-" and "Z" may be "z". The fraction of a second is accepted but dropped.
#   Output: YYYY-MM-DDThh:mm:ss(Z|+hh:mm), with "Z" for UTC.
# A datetime without a time zone, which ISO 8601 regards as local time, is rejected as an error, so that every datetime can be normalized unambiguously. The epoch seconds are counted in UTC.
# [RFC 3339 vs ISO 8601](https://ijmacd.github.io/rfc3339-iso8601/)
# Each function that outputs a value prints it, or assigns it to the variable given with "-v var" as printf of Bash does. The value is computed by an inner function with a hash-suffixed name, which sets it to result_b20e134 and is free to use any local variables, so that they do not shadow the variable whose name is given by the caller.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

iso_datetime_format_590c473='%Y-%m-%dT%H:%M:%S%z'
iso_datetime_format_utc_590c473='%Y-%m-%dT%H:%M:%SZ'

result_b20e134=

# Normalize the time zone at the end of each ISO datetime line, which date(1) writes as "+0900" or "+09:00", into "Z" for UTC or "+09:00" otherwise.
normalize_timezone_590c473() {
  sed -E \
    -e 's/[+-]00:?00$/Z/' \
    -e 's/([+-][0-9]{2})([0-9]{2})$/\1:\2/'
}

date_iso_print_c466a97() {
  if is_bbwin
  then
    # -I[SPEC]: Output ISO-8601 date / SPEC=date (default), hours, minutes, seconds or ns
    date -Iseconds
  elif is_macos
  then
    # -j: Do not try to set the dates
    date -j +"$iso_datetime_format_590c473"
  else
    date +"$iso_datetime_format_590c473"
  fi \
  | normalize_timezone_590c473
}

date_iso_64440b6() {
  result_b20e134="$(date_iso_print_c466a97 "$@")"
}

# Output current date and time in ISO-8601 format.
# Usage: date_iso [-v var]
# Example: date_iso  # => 2024-01-01T12:00:00+09:00
date_iso() {
  local var_name_6b8cd62=
  test "${1-}" = "-v" && var_name_6b8cd62="$2" && shift 2
  date_iso_64440b6 "$@" || return $?
  print_to "$var_name_6b8cd62" "$result_b20e134"
}

iso_to_epoch_print_1d6235e() {
  local iso_date="$1"
  # Reject a datetime without a time zone on every platform, rather than regarding it as local.
  local zone
  iso_datetime_timezone_8324622 "$iso_date"; zone="$result_b20e134"
  if test -z "$zone"
  then
    echo "No time zone in \"$iso_date\"." >&2
    return 1
  fi
  if is_macos
  then
    # BSD date(1) reads the time zone with "%z" only as "+0900". Normalize "Z", "+09:00" and "+09" into that form, and drop the fraction of a second, which it cannot read either.
    local time="${iso_date#*T}"
    time="${time%%[.,Zz+-]*}"
    local datetime="${iso_date%%T*}T$time"
    case "$zone" in
      ([Zz]) zone=+0000;;
      ([+-][0-9][0-9]:[0-9][0-9]) zone="${zone%:*}${zone##*:}";;
      ([+-][0-9][0-9]) zone="${zone}00";;
    esac
    date -j -f "$iso_datetime_format_590c473" "$datetime$zone" +%s
  elif is_windows
  then
    pwsh.exe -NoProfile -Command "Get-Date \"$iso_date\" -UFormat %s"
  else
    date -d "$iso_date" +%s
  fi
}

iso_to_epoch_7e83daf() {
  result_b20e134="$(iso_to_epoch_print_1d6235e "$@")"
}

# Convert an ISO-8601 date string to UNIX epoch seconds.
# Usage: iso_to_epoch [-v var] <ISO_time>
# Example: iso_to_epoch 2024-01-01T12:00:00+0900  # => 1704078000
iso_to_epoch() {
  local var_name_b273087=
  test "${1-}" = "-v" && var_name_b273087="$2" && shift 2
  iso_to_epoch_7e83daf "$@" || return $?
  print_to "$var_name_b273087" "$result_b20e134"
}

epoch_to_iso_print_22ee245() {
  local epoch="$1"
  if test -z "$epoch"
  then
    return 1
  fi
  if is_macos
  then
    date -j -r "$epoch" +"$iso_datetime_format_590c473"
  else
    date -d @"$epoch" +"$iso_datetime_format_590c473"
  fi \
  | normalize_timezone_590c473
}

epoch_to_iso_0cf9002() {
  result_b20e134="$(epoch_to_iso_print_22ee245 "$@")"
}

# Convert UNIX epoch seconds to an ISO-8601 date string.
# Usage: epoch_to_iso [-v var] <epoch>
# Example: epoch_to_iso 1704078000  # => 2024-01-01T12:00:00+09:00
epoch_to_iso() {
  local var_name_9e0e638=
  test "${1-}" = "-v" && var_name_9e0e638="$2" && shift 2
  epoch_to_iso_0cf9002 "$@" || return $?
  print_to "$var_name_9e0e638" "$result_b20e134"
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
    echo "Usage: $(arg0_basename) --mtime=<ISO_time> <file>..." >&2
    return 1
  fi
  local zone
  iso_datetime_timezone_8324622 "$mtime"; zone="$result_b20e134"
  if test -z "$zone"
  then
    echo "No time zone in \"$mtime\"." >&2
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
    # BSD touch(1) accepts no time zone other than "Z". Convert to UTC through the epoch, so that any form that iso_to_epoch accepts can be given.
    local epoch
    epoch="$(iso_to_epoch "$mtime")" || return $?
    mtime="$(TZ=UTC0 date -j -r "$epoch" +"$iso_datetime_format_utc_590c473")"
  fi
  touch -d "$mtime" "$@"
}

last_mod_iso_print_bb54c05() {
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
    date -d @"$epoch" -Iseconds
  else
    date --date "$(stat --format "%y" "$file")" +"$iso_datetime_format_590c473"
  fi \
  | normalize_timezone_590c473
}

last_mod_iso_2622fbe() {
  result_b20e134="$(last_mod_iso_print_bb54c05 "$@")"
}

# Output last modification time of a file in ISO-8601 format.
# Usage: last_mod_iso [-v var] <file>
# Example: last_mod_iso file.txt  # => 2024-01-01T12:00:00+09:00
last_mod_iso() {
  local var_name_ccb3c5a=
  test "${1-}" = "-v" && var_name_ccb3c5a="$2" && shift 2
  last_mod_iso_2622fbe "$@" || return $?
  print_to "$var_name_ccb3c5a" "$result_b20e134"
}

# ==========================================================================
#region Extract ISO datetime components.

iso_datetime_year_25dd9ce() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime%%-*}"
}

# Extract the year of the ISO datetime.
# Usage: iso_datetime_year [-v var] <ISO_datetime>
iso_datetime_year() {
  local var_name_2d11c00=
  test "${1-}" = "-v" && var_name_2d11c00="$2" && shift 2
  iso_datetime_year_25dd9ce "$@" || return $?
  print_to "$var_name_2d11c00" "$result_b20e134"
}

iso_datetime_month_ec3e4f1() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*-}"
  result_b20e134="${result_b20e134%%-*}"
}

# Extract the month of the ISO datetime.
# Usage: iso_datetime_month [-v var] <ISO_datetime>
iso_datetime_month() {
  local var_name_ee105db=
  test "${1-}" = "-v" && var_name_ee105db="$2" && shift 2
  iso_datetime_month_ec3e4f1 "$@" || return $?
  print_to "$var_name_ee105db" "$result_b20e134"
}

iso_datetime_day_bc6befe() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*-}"
  result_b20e134="${result_b20e134#*-}"
  result_b20e134="${result_b20e134%%T*}"
}

# Extract the day of the ISO datetime.
# Usage: iso_datetime_day [-v var] <ISO_datetime>
iso_datetime_day() {
  local var_name_f0b630f=
  test "${1-}" = "-v" && var_name_f0b630f="$2" && shift 2
  iso_datetime_day_bc6befe "$@" || return $?
  print_to "$var_name_f0b630f" "$result_b20e134"
}

iso_datetime_hour_2d32609() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134%%:*}"
}

# Extract the hour of the ISO datetime.
# Usage: iso_datetime_hour [-v var] <ISO_datetime>
iso_datetime_hour() {
  local var_name_8915ff5=
  test "${1-}" = "-v" && var_name_8915ff5="$2" && shift 2
  iso_datetime_hour_2d32609 "$@" || return $?
  print_to "$var_name_8915ff5" "$result_b20e134"
}

iso_datetime_minute_cbdb6d5() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134#*:}"
  result_b20e134="${result_b20e134%%:*}"
}

# Extract the minute of the ISO datetime.
# Usage: iso_datetime_minute [-v var] <ISO_datetime>
iso_datetime_minute() {
  local var_name_6d1af76=
  test "${1-}" = "-v" && var_name_6d1af76="$2" && shift 2
  iso_datetime_minute_cbdb6d5 "$@" || return $?
  print_to "$var_name_6d1af76" "$result_b20e134"
}

iso_datetime_second_a08d944() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134#*:}"
  result_b20e134="${result_b20e134#*:}"
  # Drop what follows the digits, such as the fraction of a second and the time zone ("Z" or "+0900").
  result_b20e134="${result_b20e134%%[!0-9]*}"
}

# Extract the second of the ISO datetime.
# Usage: iso_datetime_second [-v var] <ISO_datetime>
iso_datetime_second() {
  local var_name_2c8d9a8=
  test "${1-}" = "-v" && var_name_2c8d9a8="$2" && shift 2
  iso_datetime_second_a08d944 "$@" || return $?
  print_to "$var_name_2c8d9a8" "$result_b20e134"
}

# The time zone is what follows the time, starting with "Z", "+" or "-", such as "Z", "+0900" or "-05:00". It is empty if not given.
iso_datetime_timezone_8324622() {
  local iso_datetime="$1"
  result_b20e134="${iso_datetime#*T}"
  result_b20e134="${result_b20e134#"${result_b20e134%%[Zz+-]*}"}"
}

# Extract the time zone of the ISO datetime.
# Usage: iso_datetime_timezone [-v var] <ISO_datetime>
iso_datetime_timezone() {
  local var_name_ad4f11f=
  test "${1-}" = "-v" && var_name_ad4f11f="$2" && shift 2
  iso_datetime_timezone_8324622 "$@" || return $?
  print_to "$var_name_ad4f11f" "$result_b20e134"
}

#endregion

# ==========================================================================
#region Convert ISO datetime.

iso_datetime_to_utc_a8c54bd() {
  local epoch_seconds
  iso_to_epoch -v epoch_seconds "$1" || return $?
  result_b20e134="$(TZ=UTC0 epoch_to_iso_print_22ee245 "$epoch_seconds")"
}

# Convert the ISO datetime with a time zone to UTC.
# Usage: iso_datetime_to_utc [-v var] <ISO_datetime>
# Example: iso_datetime_to_utc 2025-01-01T09:00:00+0900  # => 2025-01-01T00:00:00Z
iso_datetime_to_utc() {
  local var_name_d364541=
  test "${1-}" = "-v" && var_name_d364541="$2" && shift 2
  iso_datetime_to_utc_a8c54bd "$@" || return $?
  print_to "$var_name_d364541" "$result_b20e134"
}

#endregion
