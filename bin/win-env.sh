#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_959ea36-false}" && return 0; sourced_959ea36=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
cd "$3" || exit; shift 3

# shellcheck disable=SC2046
win_env() {
  is_windows || return 1

  local IFS=';'

  echo '# User'
  # (Get-ItemProperty -Path "HKCU:\Environment").Path # Expands `%Path%`
  set -- $(
    # shellcheck disable=SC2016
    pwsh.exe -NoProfile --Command '
      $key = Get-Item -Path "HKCU:\Environment"
      $key.GetValue("Path", $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
    '
  )
  # set -- $(pwsh -NoProfile -Command '[Environment]::GetEnvironmentVariable("Path", "User")')
  printf "%s\n" "$@"

  echo

  echo '# Machine'
  set -- $(
    # shellcheck disable=SC2016
    pwsh.exe -NoProfile --Command '(Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Session Manager\Environment").Path'
  )
  printf "%s\n" "$@"
 }

case "${0##*/}" in
  (win-env.sh|win-env)
    set -o nounset -o errexit
    win_env "$@"
    ;;
esac
