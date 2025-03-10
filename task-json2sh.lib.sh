#!/bin/sh
test "${guard_5c3f500+set}" = set && return 0; guard_5c3f500=-

. ./task.sh

if test -r ./task-volta.lib.sh && test -r ./json2sh.mjs
then
  . ./task-volta.lib.sh
elif test -r ./task-jq.lib.sh
then
  . ./task-jq.lib.sh
else
  echo "No appropriate JSON parser found." >&2
  exit 1
fi

subcmd_json2sh() ( # Convert JSON to shell script.
  if command -v subcmd_volta >/dev/null 2>&1 && test -r ./json2sh.mjs
  then
    subcmd_volta run node json2sh.mjs "$@"
  elif command -v subcmd_jq >/dev/null 2>&1
  then
    # shellcheck disable=SC2016
    subcmd_jq -r '
def to_sh(prefix):
  to_entries[] |
  .key as $k |
  ($k | gsub("[-\\.]"; "_")) as $keyForShell |
  if (.value | type == "object") then
    .value | to_sh("\(prefix)\($keyForShell)__")
  else
    "\(prefix)\($keyForShell)=\"\(.value)\""
  end;

to_sh("json__")
'
  else
    echo "No appropriate JSON parser found." >&2
    exit 1
  fi
)
