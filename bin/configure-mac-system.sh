#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ ff007c8 && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR ./.lib "$@"
. ./.lib/utils.sh
shift 2
cd "$1" || exit 1; shift 2

configure_mac_system() {
  if ! is_macos
  then
    echo "For MacOS." >&2
    return 1
  fi

  # スクリーンロックからの復帰には即パスワード要求
  sysadminctl -password - -screenLock immediate

  # The -a, -b, -c, -u flags determine whether the settings apply to battery ( -b ), charger (wall power) ( -c ), UPS ( -u ) or all ( -a ).
  sudo pmset -a standby 1
  # コマンドで sleep させる際に hibernate mode を指定する方法はなさげ。charger では safe sleep, battery では deep sleep にしてみる
  sudo pmset -b hibernatemode 25
  sudo pmset -b displaysleep 3
  sudo pmset -b sleep 10
  sudo pmset -c hibernatemode 3
  sudo pmset -c displaysleep 10
  sudo pmset -c sleep 0
  # Powernap をオフにしておけば、カバンの中で勝手に復帰することはなくなるかな？ なくなって欲しい
  sudo pmset -a powernap 0
}

# $ pmset -g custom
# Battery Power:
#  Sleep On Power Button 1
#  lowpowermode         1
#  standby              1
#  ttyskeepawake        1
#  hibernatemode        3
#  powernap             0
#  hibernatefile        /var/vm/sleepimage
#  displaysleep         2
#  womp                 0
#  networkoversleep     0
#  sleep                1
#  lessbright           1
#  tcpkeepalive         1
#  disksleep            10
#  SleepServices        0
# AC Power:
#  Sleep On Power Button 1
#  lowpowermode         0
#  standby              1
#  ttyskeepawake        1
#  hibernatemode        3
#  powernap             0
#  hibernatefile        /var/vm/sleepimage
#  displaysleep         10
#  womp                 1
#  networkoversleep     0
#  sleep                0
#  tcpkeepalive         1
#  disksleep            10
#  SleepServices        0

_() { test "${0##*/}" = "$1" -o "${0##*\\}" = "$1" -o "${0##*/}" = "$1.sh" -o "${0##*\\}" = "$1.sh"; }; if _ configure_mac_system | _ configure-mac-system
then
  set -o nounset -o errexit
  configure_mac_system
   "$@"
fi
