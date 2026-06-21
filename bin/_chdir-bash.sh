# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh

cd "$1" || exit 1
shift
exec bash "$@"
