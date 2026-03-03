# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_16625c1-false}" && return 0; sourced_16625c1=true

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
. ./.lib/utils.lib.sh
shift 2
cd "$1" || exit 1; shift 2

# Spago
task_spago() {
  spago "$@"
}

# Bundle
task_bundle() {
  push_dir "$PROJECT_DIR"
  local dir=.spago/bundle
  mkdir -p "$dir"
  spago bundle --outfile=$dir/index.js "$@"
  pop_dir
}

# Build
task_build() {
  spago build "$@"
}

# Run
task_run() {
  spago run "$@"
}

case "${0##*/}" in
  (tasks-project.sh|tasks-project)
    set -o nounset -o errexit
    "$@"
    ;;
esac
