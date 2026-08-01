#!/usr/bin/env sh
set -- _PY__MISE_TASKS_BUILD_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return # shpp:source_guard

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../../../.lib "$OLDPWD" "$@" # shpp:sources
. ../../../.lib/utils.sh
. ../../../.lib/embed-script.sh
cd "$3" || exit; shift 3 # /shpp:sources

build() {
  embed_minified \
    "$TASK_PROJECT_DIR"/.mise/tasks-project.bash \
    #nop
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (build.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  build "$@"
fi
