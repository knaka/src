# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_ab72cef-false}" && return 0; sourced_ab72cef=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

# The Haskell Tool Stack
task_stack() {
  stack "$@"
}

# Glasgow Haskell Compiler
task_ghc() {
  stack exec ghc "$@"
}

# Glasgow Haskell Compiler Interpreter
task_ghci() {
  stack exec ghci "$@"
}

# Build
task_build() {
  stack build hsprj:main-exe "$@"
  local cmd_path
  if is_windows
  then
    # Fixme
    cmd_path="$(stack exec cygpath -- --windows "$cmd_path")"
  else
    cmd_path="$(stack exec which main-exe)"
  fi
  mkdir -p ./build/
  cp -a "$cmd_path" ./build/
  echo Copied the command to: ./build/"$(basename "$cmd_path")" >&2
}

# stack haddock --dependencies-only

case "${0##*/}" in
  (tasks-project.sh|tasks-project)
    set -o nounset -o errexit
    "$@"
    ;;
esac
