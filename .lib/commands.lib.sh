# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_be37450-false}" && return 0; sourced_be37450=true

# Provides commands that are invoked outside of Mise project.

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
. ./utils.lib.sh
shift 2
if test "${MISE_CONFIG_ROOT+set}" != set
then
  . ./../mise
fi
cd "$1" || exit 1; shift

jq() {
  is_windows && set -- --binary "$@"
  mise exec jq -- jq "$@"
}

# Under Mise environment context, this file is not required.
test "${MISE_CONFIG_ROOT+set}" = set && return 0

export MISE_ACTIVATE_AGGRESSIVE=true

caddy() { mise exec caddy -- caddy "$@"; } 
chezmoi() { mise exec chezmoi -- chezmoi "$@"; }
claude() { mise exec "npm:@anthropic-ai/claude-code" -- claude "$@"; }
gemini() { mise exec "npm:@google/gemini-cli" -- gemini "$@"; }
ghq() { mise exec ghq -- ghq "$@"; }
go() { mise exec go -- go "$@"; }
gofmt() { mise exec go -- gofmt "$@"; }
gum() { mise exec gum -- gum "$@"; }
jmespath() { mise exec jmespath -- jp "$@"; }
lua() { mise exec lua -- lua "$@"; }
mdpp() { mise exec "github:knaka/mdpp" -- mdpp "$@"; }
mlr() { mise exec miller -- mlr "$@"; }
node() { mise exec node -- node "$@"; }
npm() { mise exec node -- npm "$@"; }
npx() { mise exec node -- npx "$@"; }
peco() { mise exec "go:github.com/knaka/peco/cmd/peco@latest" -- peco "$@"; }
perl() { mise exec perl -- perl "$@"; }
python() { mise exec python -- python "$@"; }
tblcalc() { mise exec "github:knaka/tblcalc" -- tblcalc "$@"; }
yj() { mise exec yj -- yj "$@"; } # sclevine/yj: CLI - Convert between YAML, TOML, JSON, and HCL. Preserves map order. https://github.com/sclevine/yj
yq() { mise exec yq -- yq "$@"; }
