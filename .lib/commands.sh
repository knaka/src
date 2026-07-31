# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
set -- __LIB_COMMANDS_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

# Provides commands that are invoked outside of Mise project.

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR . "$OLDPWD" "$@" # shpp:sources
. ./utils.sh
shift 2; set -- _SCRDIR ./.. "$@" # shpp:sources_chdir
if ! has_external_command mise >/dev/null 2>&1
then
  . ./../mise
fi
cd "$3" || exit; shift 3 # /shpp:sources

export MISE_ACTIVATE_AGGRESSIVE=true

# Mise tasks do not require this script.
is_mise && return

caddy() { mise exec caddy@latest -- caddy "$@"; } 
chezmoi() { mise exec chezmoi@latest -- chezmoi "$@"; }
claude() { mise exec "npm:@anthropic-ai/claude-code@latest" -- claude "$@"; }
gemini() { mise exec "npm:@google/gemini-cli@latest" -- gemini "$@"; }
ghq() { mise exec ghq@latest -- ghq "$@"; }
go() { mise exec go@latest -- go "$@"; }
gofmt() { mise exec go@latest -- gofmt "$@"; }
gum() { mise exec gum@latest -- gum "$@"; }
htmlq() { mise exec htmlq@latest -- htmlq "$@"; }
jmespath() { mise exec jmespath@latest -- jp "$@"; }
jq() { mise exec jq@latest -- jq "$@"; }
lua() { mise exec lua@latest -- lua "$@"; }
mdpp() { mise exec github:knaka/mdpp@latest -- mdpp "$@"; }
mlr() { mise exec miller@latest -- mlr "$@"; }
node() { mise exec node@latest -- node "$@"; }
npm() { mise exec node@latest -- npm "$@"; }
npx() { mise exec node@latest -- npx "$@"; }
peco() { mise exec go:github.com/knaka/peco/cmd/peco@latest@latest -- peco "$@"; }
perl() { mise exec perl@latest -- perl "$@"; }
python() { mise exec python@latest -- python "$@"; }
tblcalc() { mise exec github:knaka/tblcalc@latest -- tblcalc "$@"; }
yj() { mise exec yj@latest -- yj "$@"; } # sclevine/yj: CLI - Convert between YAML, TOML, JSON, and HCL. Preserves map order. https://github.com/sclevine/yj
yq() { mise exec yq@latest -- yq "$@"; }
skills() { mise exec "npm:skills@latest" -- skills "$@"; }
