# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_be37450-false}" && return 0; sourced_be37450=true

# Provides commands that are invoked outside of Mise project.

test "${_APPDIR+set}" = set || { cd "${0%/*}" || cd "${0%\\*}" || cd . || exit 1; _APPDIR="$PWD"; cd "$OLDPWD" || exit 1; } 2>/dev/null
if test "${1:+$1}" = _LIBDIR; then cd "$2" || exit 1; else cd "$_APPDIR" || exit 1; fi; set -- "$OLDPWD" "$@"
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
if ! which mise >/dev/null 2>&1
then
  . ./../mise
fi
cd "$1" || exit 1; shift

export MISE_ACTIVATE_AGGRESSIVE=true

jq() {
  set -- --binary "$@"
  if which jq >/dev/null 2>&1
  then
    command jq "$@"
    return "$?"
  fi
  mise exec jq@latest -- jq "$@"
}

# Mise tasks do not require this script.
test "${MISE_CONFIG_ROOT+set}" = set && return 0

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
