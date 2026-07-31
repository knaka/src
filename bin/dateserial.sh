# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_DATESERIAL_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Retrieves the current UTC time and formats a string consisting of the year, month, day, and the degree of progression through the day (calculated by dividing the hour by 24 and then multiplying by 100). For instance, at 6 AM UTC, this code would produce an output like `2024013025`. This represents January 30, 2024, with '25' indicating that 25% of the day has passed.
dateserial() {
  hour=$(date -u '+%H')
  minute=$(date -u '+%M')
  day_progress="$(printf "%02d" $(( ((hour * 60 + minute) * 100) / (24 * 60) )) )"
  date -u '+%Y%m%d'"$day_progress"
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (dateserial.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  dateserial "$@"
fi
