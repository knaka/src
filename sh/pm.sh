#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_3da4fcd-false}" && return 0; sourced_3da4fcd=true

set -- "$PWD" "${0%/*}" "$@"; if test -z "${_APPDIR-}"; then _APPDIR=.; if test "$2" != "$0"; then _APPDIR="$2"; fi; cd "$_APPDIR" || exit 1; fi
cd "$1"; shift 2

pm() {
  if command -v dpkg >/dev/null 2>&1
  then
    pm_dpkg "$@"
  elif command -v brew >/dev/null 2>&1
  then
    pm_brew "$@"
  fi
}

pm_dpkg() {
  case "$1" in
    (-qa) shift; dpkg -l "$@" ;;
    (-qf) shift; dpkg -S "$@" ;;
    (-qi) shift; dpkg -s "$@" ;;
    (-ql) shift; dpkg -L "$@" ;;
    (-q)
      shift
      case "$1" in
        (--scripts)
          shift
          ls -l /var/lib/dpkg/info/"$1".* ;;
      esac
      ;;
    (*) dpkg "$@" ;;
  esac
}

# homebrew-core/Formula at main · Homebrew/homebrew-core https://github.com/Homebrew/homebrew-core/tree/main/Formula
pm_brew() {
  case "$1" in
    (-qa) shift; brew list "$@" ;;
    # (-qf) shift; brew ? "$@" ;; できません
    (-qi) shift; brew info "$@" ;;
    (-ql) shift; brew list "$@" ;;
    (-q)
      shift
      case "$1" in
        (--scripts)
          shift
          ls -l /usr/local/opt/"$1"/.brew/"$1".rb
          ;;
      esac
      ;;
    (*) brew "$@" ;;
  esac
}

case "${0##*/}" in
  (pm.sh|pm)
    set -o nounset -o errexit
    pm "$@"
    ;;
esac
