# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- _BIN_LAUNCH_CLAUDE_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./set-terminal-title.sh
cd "$3" || exit; shift 3 # /shpp:sources

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
  if test $(($(date +%s) % 30)) -eq 0
  then
    claude update >&2
  fi
}

if eval test '"$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (launch-claude.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  launch_claude "$@"
fi
