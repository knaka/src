#!/usr/bin/env bash
set -- _BIN_CLAUDE_CONVERSATION_TO_MD_BASH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
. ../.lib/time.sh
popd >/dev/null || exit

# “projects/<project>/<session>.jsonl: Full conversation transcript: every message, tool call, and tool result”
# — Explore the .claude directory - Claude Code Docs https://code.claude.com/docs/en/claude-directory

extract_session_id() { jq --raw-output '
  select(.sessionId != null) | .sessionId, halt
' "$@"; }

extract_title_3ab66fa() { jq --null-input --raw-input --raw-output '
  [
    inputs
    | fromjson?
    | select(.type=="ai-title")
    | .aiTitle
  ]
  | last
' "$@"; }

front_matter_44478fb() { cat <<EOF
---
id: "$id"
session_id: "$session_id"
title: "$title - Claude Code"
tags: []
created_at: "$datetime"
---
EOF
}

body_904b37e() { jq --raw-output '
  . as $msg
  | .message.content[]? | select(.type=="text" and (.text | test("\\S")))
  |
    "# " + $msg.message.role + "\n",
    .text + "\n"
' "$@"; }

claude_conversation_file_to_md() {
  local file="$1"
  local session_id
  session_id="$(extract_session_id "$file")"
  local id="${session_id:0:7}"
  local title
  title="$(extract_title_3ab66fa "$file")"
  local datetime
  datetime="$(date_iso)"
  front_matter_44478fb
  body_904b37e "$file"
}

claude_conversation_to_md() {
  if test $# -eq 0
  then
    echo Specify the conversation file path or search words. >&2
    return 1
  fi
  local file
  if test -r "$1"
  then
    file="$1"
  else
    local -a args
    local word
    for word in "$@"
    do
      args+=(-exec grep -q "$word" {} ';' -a)
    done
    local -a files
    while read -r; do files+=("$REPLY"); done \
    < <(find "$HOME"/.claude/projects/*/*.jsonl "${args[@]}" -print)
    if test ${#files[@]} -eq 0
    then
      echo "No match." >&2
      return 1
    elif test ${#files[@]} -gt 1
    then
      echo "Matched multiple files:" >&2
      printf "  %s\n" "${files[@]}"
      return 1
    fi
    file="${files[0]}"
    echo "Target file: $file" >&2
  fi
  claude_conversation_file_to_md "$file"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  claude_conversation_to_md "$@"
fi
