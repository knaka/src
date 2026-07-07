# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 9df65a0 && return 0

echo a83a64b $OLDPWD
cd /
echo c4df458 $OLDPWD
