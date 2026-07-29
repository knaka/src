#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_CONFIGURE_MAC_SYSTEM_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../.lib "$OLDPWD" "$@" # shpp:sources
. ../.lib/utils.sh
cd "$3" || exit; shift 3 # /shpp:sources

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

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (configure-mac-system.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  configure_mac_system
   "$@"
fi
