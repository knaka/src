#!/usr/bin/env bash
set -- _ce9587e "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

gen_markdown_frontmatter() { cat <<EOF
---
id: "$id7"
title: "Claude - $name"
tags: []
created_at: "$created_at"
---
EOF
}

gen_markdown() {
  echo
  echo "> From: https://claude.ai/chat/$id"
  # With `tree=true`, `chat_messages` also holds branches left by edits and retries, so follow the parent links from `current_leaf_message_uuid` to get only the branch shown on screen. Only `text` blocks are output; thinking and tool blocks are skipped.
  jq -r '
    (.chat_messages | map({key: .uuid, value: .}) | from_entries) as $by_uuid
    | if .current_leaf_message_uuid then
        [.current_leaf_message_uuid | recurse($by_uuid[.].parent_message_uuid; $by_uuid[.] != null) | $by_uuid[.]] | reverse
      else
        .chat_messages | sort_by(.index)
      end
    | .[]
    | "",
      (if .sender == "human" then "# Human" else "# Assistant" end),
      "",
      ([.content[] | select(.type == "text") | .text] | join("\n\n"))
  ' <"$file"
}

claude_conv_gen() {
  local doc_dir="$HOME/doc"
  if ! test -d "$doc_dir"
  then
    echo 00e4557 >&2
    return 1
  fi
  local file
  for file in "$@"
  do
    local epoch year month day
    # `fromdateiso8601` only accepts `%Y-%m-%dT%H:%M:%SZ`, so drop fractional seconds and normalize a `+00:00` offset to `Z` first.
    epoch="$(jq -r '.created_at | sub("\\.[0-9]+"; "") | sub("\\+00:00$"; "Z") | fromdateiso8601' "$file")"
    year="$(jq -rn --argjson t "$epoch" '$t | strftime("%Y")')"
    month="$(jq -rn --argjson t "$epoch" '$t | strftime("%m")')"
    day="$(jq -rn --argjson t "$epoch" '$t | strftime("%d")')"
    mkdir -p "$doc_dir/$year"
    local id id7 name
    id="$(jq -r .uuid "$file")"
    id7="${id:0:7}"
    local out="$doc_dir/$year/$month$day-$id7.md"
    local base
    base="$(basename "$out")"
    echo "* [](./$base)<!-- +SYNC_TITLE -->" >&2
    name="$(jq -r .name "$file")"
    created_at="$(jq -r .created_at "$file")"
    {
      gen_markdown_frontmatter
      gen_markdown
    } >"$out"
  done
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 claude_conv_gen "$@"
fi
