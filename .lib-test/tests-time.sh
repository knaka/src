# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_6cc6268-false}" && return 0; sourced_6cc6268=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/time.sh
. ../.lib/assert.sh
. ../.lib/test.sh
cd "$3" || exit; shift 3

test_time() {
  skip_if is_bbwin

  init_temp_dir

  local result

  # Outputs current date and time in ISO-8601 format.
  result="$(date_iso)"
  assert_match '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}\+[[:digit:]]{4}$' "$result"

  # Outputs current date and time in ISO-8601 format in UTC.
  result="$(TZ=UTC0 date_iso)"
  assert_match '^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}:[[:digit:]]{2}\+0000$' "$result"

  local file="$TEMP_DIR"/file
  touch "$file"

  # Sets timestamp with UTC date.
  touch_time_iso --mtime="2024-01-01T12:00:00Z" "$file"
  assert_eq "$(TZ=UTC0 last_mod_iso "$file")" "2024-01-01T12:00:00+0000"
  assert_eq "$(TZ=Asia/Tokyo last_mod_iso "$file")" "2024-01-01T21:00:00+0900"

  # Sets timestamp with a date with timezone offset.
  touch_time_iso --mtime="2024-01-01T09:00:00+0900" "$file"
  assert_eq "$(TZ=UTC0 last_mod_iso "$file")" "2024-01-01T00:00:00+0000"
  assert_eq "$(TZ=Asia/Tokyo last_mod_iso "$file")" "2024-01-01T09:00:00+0900"

  # Converts date to epoch.
  assert_eq 1735732800 "$(iso_to_epoch "2025-01-01T12:00:00Z")"
  assert_eq 1735700400 "$(iso_to_epoch "2025-01-01T12:00:00+0900")"

  # Converts epoch to date.
  assert_eq "2025-01-01T12:00:00+0000" "$(TZ=UTC0 epoch_to_iso 1735732800)"
  assert_eq "2025-01-01T12:00:00+0900" "$(TZ=Asia/Tokyo epoch_to_iso 1735700400)"
}
