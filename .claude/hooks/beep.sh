# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_5b8e432-false}" && return 0; sourced_5b8e432=true

if test -d "c:/" -a ! -d /proc
then
  pwsh -c "[console]::beep(1000,300)" &
elif test -r /System/Library/CoreServices/SystemVersion.plist
then
  osascript -e 'beep' &
fi
