#!/usr/bin/env bash
set -- _e0d1934 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

s="$(printf "%s%s \t$CH_LF$CH_US&:!'''" '"' "'")"

print_credential() {
  printf "%s" "$s"  
}

quote_printf() {
  local CREDENTIAL=

  # For sh
  CREDENTIAL="$(print_credential)"
  test "$CREDENTIAL" = "$s"

  # %q is Bash specific
  local assignment=
  printf -v assignment "CREDENTIAL=%q" "$(print_credential)"
  eval "$assignment"
  test "$CREDENTIAL" = "$s"

  # -v is also Bash specific
  printf -v CREDENTIAL "%s" "$(print_credential)"
  test "$CREDENTIAL" = "$s"

  printf "869998b: %s\n" "$CREDENTIAL" >&2
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  quote_printf "$@"
fi
