# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ b0cdf45 && return 0

{ pushd "${BASH_SOURCE[0]%/*}" || pushd "${BASH_SOURCE[0]%\\*}" || pushd .; } >/dev/null 2>&1
set -- _LIBDIR . "$@"
. ./utils.sh
shift 2
popd >/dev/null || exit 1

# ==========================================================================
#region Misc.

# Sometimes shellcheck cannot find the definitions in sub files.
: "${lwb:=(^|[^[:alnum:]_])}"
: "${rwb:=($|[^[:alnum:]_])}"

#endregion
