#!/usr/bin/env sh
set -- __LIB_TEST_TESTS_DATETIME_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
. ../.lib/datetime.sh
. ../.lib/assert.sh
. ../.lib/test.sh
cd "$3" || exit; shift 3 # /shpp:sources

test_datetime() {
  skip_if is_bbwin

  init_temp_dir

  local result

  # Outputs current date and time in ISO-8601 format.
  result="$(date_iso)"
  assert_match '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}(Z|[+-][[:digit:]]{2}:[[:digit:]]{2})$' "$result"

  # Outputs current date and time in ISO-8601 format in UTC.
  result="$(TZ=UTC0 date_iso)"
  assert_match '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}Z$' "$result"

  local file="$TEMP_DIR"/file
  touch "$file"

  # Sets timestamp with UTC date.
  touch_iso --mtime="2024-01-01T12:00:00Z" "$file"
  assert_eq "$(TZ=UTC0 last_mod_iso "$file")" "2024-01-01T12:00:00Z"
  assert_eq "$(TZ=Asia/Tokyo last_mod_iso "$file")" "2024-01-01T21:00:00+09:00"

  # Sets timestamp with a date with timezone offset.
  touch_iso --mtime="2024-01-01T09:00:00+0900" "$file"
  assert_eq "$(TZ=UTC0 last_mod_iso "$file")" "2024-01-01T00:00:00Z"
  assert_eq "$(TZ=Asia/Tokyo last_mod_iso "$file")" "2024-01-01T09:00:00+09:00"

  # Converts date to epoch.
  assert_eq 1735732800 "$(iso_to_epoch "2025-01-01T12:00:00Z")"
  assert_eq 1735700400 "$(iso_to_epoch "2025-01-01T12:00:00+0900")"

  # Converts epoch to date.
  assert_eq "2025-01-01T12:00:00Z" "$(TZ=UTC0 epoch_to_iso 1735732800)"
  assert_eq "2025-01-01T12:00:00+09:00" "$(TZ=Asia/Tokyo epoch_to_iso 1735700400)"

  # Extracts each component.
  local iso_datetime="2025-01-02T12:23:34+0000"
  assert_eq "2025" "$(iso_datetime_year "$iso_datetime")"
  assert_eq "01" "$(iso_datetime_month "$iso_datetime")"
  assert_eq "02" "$(iso_datetime_day "$iso_datetime")"
  assert_eq "12" "$(iso_datetime_hour "$iso_datetime")"
  iso_datetime_hour_ "$iso_datetime"
  # shellcheck disable=SC2153
  assert_eq "$RESULT" 12
  assert_eq "23" "$(iso_datetime_minute "$iso_datetime")"
  assert_eq "34" "$(iso_datetime_second "$iso_datetime")"
  assert_eq "+0000" "$(iso_datetime_timezone "$iso_datetime")"

  # Converts to UTC.
  assert_eq "2025-01-01T00:00:00Z" "$(iso_datetime_to_utc "2025-01-01T09:00:00+0900")"
  assert_eq "2025-01-01T00:00:00Z" "$(iso_datetime_to_utc "2025-01-01T00:00:00Z")"
  assert_eq "2024-02-29T16:00:00Z" "$(iso_datetime_to_utc "2024-03-01T01:00:00+09:00")"
  assert_eq "2025-01-01T01:30:00Z" "$(iso_datetime_to_utc "2024-12-31T20:00:00.123-05:30")"
  assert_eq "1969-12-31T15:00:00Z" "$(iso_datetime_to_utc "1970-01-01T00:00:00+09")"
  assert_false iso_datetime_to_utc "2025-01-01T09:00:00"
}

test_timezone() {
  # Epoch is in UTC.
  assert_eq 0 "$(iso_to_epoch "1970-01-01T00:00:00Z")"
  assert_eq 0 "$(iso_to_epoch "1970-01-01T09:00:00+0900")"
  local local_datetime
  local_datetime="$(TZ=UTC+3 epoch_to_iso "$(iso_to_epoch "1970-01-01T00:00:00Z")")"
  assert_eq -- "-03:00" "$(iso_datetime_timezone "$local_datetime")"
}
