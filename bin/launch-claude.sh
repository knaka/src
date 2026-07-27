# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_f7e0683-false}" && return 0; sourced_f7e0683=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ./set-terminal-title.sh
cd "$3" || exit; shift 3

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

case "${0##*/}" in
  (launch-claude.sh|launch-claude)
    set -o nounset -o errexit
    launch_claude "$@"
    ;;
esac
