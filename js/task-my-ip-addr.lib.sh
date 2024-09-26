#!/bin/sh
set -o nounset -o errexit

subcmd_my_ip_addr() {
  eval "$(curl"$(exe_ext)" -o - http://ip.jsontest.com/ 2> /dev/null | sh "$(dirname "$0")"/task.sh json2sh)"
  # set
  # shellcheck disable=SC2154
  echo "My IP Address: $json__ip"
  exit 0
}