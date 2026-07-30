#!/usr/bin/env sh
set -- __MISE_TASKS_BUILD_SH "$@"; eval "shift; \${$1-false} || ! $1=true" && return || : # shpp:source_guard

#MISE description="Build stuff."

if test "${BASH_VERSION+set}"; then eval 'cd "${BASH_SOURCE%[/\\]*}"' || cd .; elif test "${1-}" = _SCRDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- _SCRDIR ../../.lib "$OLDPWD" "$@" # shpp:sources
. ../../.lib/utils.sh
. ../../.lib/embed-script.sh
. ../../.lib/embed-heredoc.sh
cd "$3" || exit; shift 3 # /shpp:sources

: "${LSV_EMBED_SCRIPT_TARGETS=}"
: "${LSV_EMBED_HEREDOC_TARGETS=}"

build() {
  local IFS="$CH_LF"
  # shellcheck disable=SC2086
  embed_minified $LSV_EMBED_SCRIPT_TARGETS
  # shellcheck disable=SC2086
  embed_heredoc $LSV_EMBED_HEREDOC_TARGETS
}

if eval 'test "$0" = "${BASH_SOURCE-}"' || case "${0##*[/\\]}." in (build.*) ;; (*) false;; esac # shpp:main_guard
then
  set -o nounset -o errexit
  build "$@"
fi
