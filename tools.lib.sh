# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_be37450-false}" && return 0; sourced_be37450=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR ./ptd/ "$@"
. ./task.sh
shift 2
cd "$1" || exit 1; shift

go_ver_648fd87="1.25"
node_ver_5b79749="24"

chezmoi() { mise exec chezmoi -- chezmoi "$@"; }
claude() { mise exec "npm:@anthropic-ai/claude-code" -- claude "$@"; }
ghq() { mise exec "github:x-motemen/ghq" -- ghq "$@"; }
go() { mise exec go@"$go_ver_648fd87" -- go "$@"; }
gofmt() { mise exec go@"$go_ver_648fd87" -- gofmt "$@"; }
jmespath() { mise jmespath -- jp "$@"; }
jq() { mise exec jq "$@"; }
lua() { mise exec lua -- lua "$@"; }
mdpp() { mise exec "github:knaka/mdpp" -- mdpp "$@"; }
mlr() { mise exec "github:johnkerl/miller" -- mlr "$@"; }
node() { mise exec node@"$node_ver_5b79749" -- node "$@"; }
npm() { mise exec node@"$node_ver_5b79749" -- npm "$@"; }
npx() { mise exec node@"$node_ver_5b79749" -- npx "$@"; }
peco() { mise exec "go:github.com/knaka/peco/cmd/peco@latest" -- peco "$@"; }
tblcalc() { mise exec "github:knaka/tblcalc" -- tblcalc "$@"; }
gemini() { mise exec "npm:@google/gemini-cli" -- gemini "$@"; }
yq() { mise exec yq -- yq "$@"; }
