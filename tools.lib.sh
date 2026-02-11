# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_be37450-false}" && return 0; sourced_be37450=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
. ./utils.lib.sh
. ./mise
shift 2
cd "$1" || exit 1; shift

caddy() { mise exec caddy -- caddy "$@"; } 
chezmoi() { mise exec chezmoi -- chezmoi "$@"; }
claude() { mise exec "npm:@anthropic-ai/claude-code" -- claude "$@"; }
gemini() { mise exec "npm:@google/gemini-cli" -- gemini "$@"; }
ghq() { mise exec "github:x-motemen/ghq" -- ghq "$@"; }
go() { mise exec go -- go "$@"; }
gofmt() { mise exec go -- gofmt "$@"; }
jmespath() { mise exec jmespath -- jp "$@"; }
lua() { mise exec lua -- lua "$@"; }
mdpp() { mise exec "github:knaka/mdpp" -- mdpp "$@"; }
mlr() { mise exec "github:johnkerl/miller" -- mlr "$@"; }
node() { mise exec node -- node "$@"; }
npm() { mise exec node -- npm "$@"; }
npx() { mise exec node -- npx "$@"; }
peco() { mise exec "go:github.com/knaka/peco/cmd/peco@latest" -- peco "$@"; }
perl() { mise exec perl -- perl "$@"; }
python() { mise exec python -- python "$@"; }
tblcalc() { mise exec "github:knaka/tblcalc" -- tblcalc "$@"; }
yq() { mise exec yq -- yq "$@"; }

jq() { 
  if is_windows
  then
    set -- --binary "$@"
  fi
  mise exec jq -- jq "$@"
}
