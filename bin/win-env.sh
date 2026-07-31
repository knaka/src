#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_WIN_ENV_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

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

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (win-env.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  win_env "$@"
fi
