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

# Mise tasks do not require this script.
test "${MISE_CONFIG_ROOT+set}" = set && return 0

export MISE_ACTIVATE_AGGRESSIVE=true

mise_exec() {
  if test "${_APPDIR+set}" != "set"
  then
    mise exec "$@"
    return "$?"
  fi
  push_dir "$_APPDIR"
  while test "$1" != "--"
  do
    if ! mise where "$1" >/dev/null 2>&1
    then
      mise install "$1"
    fi
    PATH="$(mise bin-paths "$1"):$PATH"
    shift
  done
  pop_dir
  export PATH
  shift
  command "$@"
}

jq() {
  is_windows && set -- --binary "$@"
  if which jq >/dev/null 2>&1
  then
    command jq "$@"
    return "$?"
  fi
  mise_exec jq@latest -- jq "$@"
}

caddy() { mise_exec caddy@latest -- caddy "$@"; } 
chezmoi() { mise_exec chezmoi@latest -- chezmoi "$@"; }
claude() { mise_exec "npm:@anthropic-ai/claude-code@latest" -- claude "$@"; }
gemini() { mise_exec "npm:@google/gemini-cli@latest" -- gemini "$@"; }
ghq() { mise_exec ghq@latest -- ghq "$@"; }
go() { mise_exec go@latest -- go "$@"; }
gofmt() { mise_exec go@latest -- gofmt "$@"; }
gum() { mise_exec gum@latest -- gum "$@"; }
htmlq() { mise_exec htmlq@latest -- htmlq "$@"; }
jmespath() { mise_exec jmespath@latest -- jp "$@"; }
lua() { mise_exec lua@latest -- lua "$@"; }
mdpp() { mise_exec github:knaka/mdpp@latest -- mdpp "$@"; }
mlr() { mise_exec miller@latest -- mlr "$@"; }
node() { mise_exec node@latest -- node "$@"; }
npm() { mise_exec node@latest -- npm "$@"; }
npx() { mise_exec node@latest -- npx "$@"; }
peco() { mise_exec go:github.com/knaka/peco/cmd/peco@latest@latest -- peco "$@"; }
perl() { mise_exec perl@latest -- perl "$@"; }
python() { mise_exec python@latest -- python "$@"; }
tblcalc() { mise_exec github:knaka/tblcalc@latest -- tblcalc "$@"; }
yj() { mise_exec yj@latest -- yj "$@"; } # sclevine/yj: CLI - Convert between YAML, TOML, JSON, and HCL. Preserves map order. https://github.com/sclevine/yj
yq() { mise_exec yq@latest -- yq "$@"; }
skills() { mise_exec "npm:skills@latest" -- skills "$@"; }
