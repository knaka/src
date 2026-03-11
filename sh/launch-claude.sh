# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f7e0683-false}" && return 0; sourced_f7e0683=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
. ./set-terminal-title.sh
cd "$1" || exit 1; shift 2

launch_claude() {
  if ! test -t 0
  then
    local terminal_title
    terminal_title="$(printf "* Claude Code (%s)" "${TERMINAL_TITLE-"$PWD"}")"
    set_terminal_title "$terminal_title"
  fi
  if test "${1+set}" = set && test "$1" = "--disable-mise"
  then
    shift
    set -- claude "$@"
  else
    set -- mise exec -- claude "$@"
  fi
  # Claude Code settings - Claude Code Docs https://code.claude.com/docs/en/settings
  env \
    DISABLE_AUTOUPDATER=1 \
    CLAUDE_CODE_DISABLE_TERMINAL_TITLE=1 \
    "$@"
  if test $(($(date +%s) % 100)) -eq 0
  then
    claude update >&2
  fi
}

case "${0##*/}" in
  (launch-claude.sh|launch-claude)
    set -o nounset -o errexit
    launch_claude "$@"
    ;;
esac
