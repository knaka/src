# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 71766cb && return 0

set -- "$PWD" "${0%/*}" "$@"; test -z "${_APPDIR-}" && { test "$2" = "$0" && _APPDIR=. || _APPDIR="$2"; cd "$_APPDIR" || exit 1; }
set -- _LIBDIR .lib "$@"
shift 2
cd "$3" || exit; shift 3

_canon_arg0() {
  local arg0
  for arg0 in \
    /home/knaka/foo/bar \
    C:\\Users\\knaka\\foo\\bar.sh \
    #nop
  do
    case ",${arg0##*/},${arg0##*\\}," in
      (*,bar,*|*,bar.sh,*)
        printf "%s\n" "$arg0"
        ;;
    esac
  done
}

case ",${0##*/},${0##*\\}," in
  (*,_canon_arg0.sh,*|*,_canon_arg0,*)
    set -o nounset -o errexit
    _canon_arg0 "$@"
    ;;
esac
