# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 38c4f72 && return 0

cd ./sh/ || exit 1
echo f117f41 $OLDPWD
. ./sourced.sh
# Deffers
echo b2b87eb $OLDPWD
