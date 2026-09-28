#!/usr/bin/env mise exec -- uv run bash
# shellcheck disable=SC1008
# shellcheck disable=SC2096
set -- _4d88df2 "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Shell tricks | mise-en-place https://mise.jdx.dev/mise-cookbook/shell-tricks.html

pushd "${BASH_SOURCE[0]%[/\\]*}" &>/dev/null || pushd . >/dev/null
. ../.lib/utils.sh
popd >/dev/null || exit

function mise_parse_env {
  printf '%s\n' "$1"
  printf '%s' "$1" | python3 -c '
import base64, pprint, sys, zlib
import msgpack
value = sys.stdin.read().strip()
if not value:
    raise SystemExit("No mise state was supplied; activate mise first")
payload = zlib.decompress(base64.b64decode(value + "=" * (-len(value) % 4)))
pprint.pprint(msgpack.unpackb(payload, raw=False), sort_dicts=False)
'
}

mise_env() {
  mise_parse_env "$__MISE_DIFF"
}

if test "$0" = "${BASH_SOURCE[0]}"
then
  set -o nounset -o errexit -o pipefail
  TAIL_DEPTH=1 mise_env "$@"
fi
