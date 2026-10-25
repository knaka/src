#!/usr/bin/env bash
set -- _9eef739 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

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

reset_macos_power_settings() {
  # The -a, -b, -c, -u flags determine whether the settings apply to battery ( -b ), charger (wall power) ( -c ), UPS ( -u ) or all ( -a ).
  pmset -a standby 1

  pmset -b displaysleep 3
  # sleep - system sleep timer (value in minutes, or 0 to disable)
  pmset -b sleep 10
  # コマンドで sleep させる際に hibernate mode を指定する方法はなさげ
  #   * sleep: 0
  #   * safesleep: 3 (default)
  #   * deepsleep: 25
  pmset -b hibernatemode 3

  pmset -c displaysleep 10
  pmset -c sleep 0
  pmset -c hibernatemode 3

  # powernap - enable/disable Power Nap on supported machines (value = 0/1)
  # “Power Nap is a macOS feature that lets your Mac perform background tasks—such as checking for Mail, Calendar, Contacts, Notes, and iCloud updates—while the computer is in sleep mode.”
  # Powernap をオフにしておけば、カバンの中で勝手に復帰することはなくなるかな？ なくなって欲しい
  pmset -a powernap 0

  # standbydelayhigh and standbydelaylow は Intel 用（“Intel Standby Mode”）で、Apple Sillicon にはないらしい
}

reset_macos_system_settings() {
  # スクリーンロックからの復帰には即パスワード要求
  sysadminctl -password - -screenLock immediate

  reset_macos_power_settings
}

ensure_root() {
  if test "$EUID" -ne 0
  then
    echo "This script requires root privileges. Re-running with sudo..."
    exec sudo bash "$0" "$@"
  fi
}

reset_system_settings() {
  if is_macos
  then
    ensure_root
    reset_macos_system_settings
  fi
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 reset_system_settings "$@"
fi
