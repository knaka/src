# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_16ef9cd-false}" && return 0; sourced_16ef9cd=true

# Hooks reference - Claude Code Docs https://code.claude.com/docs/en/hooks

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../../.lib "$OLDPWD" "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

#MISE hide=true
task_hooks__log__test() {
  printf "%s" '{"session_id":"fcf1cf4f-4629-4444-98c9-fcfd9ccf4ca0","transcript_path":"/Users/knaka/.claude/projects/-Users-knaka-repos-github-com-knaka-src/fcf1cf4f-4629-4444-98c9-fcfd9ccf4ca0.jsonl","cwd":"/Users/knaka/repos/github.com/knaka/src","hook_event_name":"SessionStart","source":"startup","model":"claude-sonnet-4-6"}' | task_hooks__log
}

#MISE hide=true
task_hooks__log() {
  local body=
  body="$(cat)"
  local hook_event=
  hook_event="$(printf '%s' "$body" | jq -r '.hook_event_name // empty')"
  {
    echo ---
    date
    printf "hook_event: %s\n" "$hook_event"
    printf "body: %s\n" "$body"
  } >>"$PROJECT_DIR"/hooks.log
}

case "${0##*/}" in
  (tasks-hooks.sh|tasks-hooks)
    set -o nounset -o errexit
    "$@"
    ;;
esac
