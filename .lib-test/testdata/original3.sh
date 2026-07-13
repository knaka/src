# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_8e8321e-false}" && return 0; sourced_8e8321e=true

py_scr_abbb7c6='print("???")' #EMBED: ./some.py

original3() {
  python -c "$py_scr_abbb7c6"
}

set -o nounset -o errexit
original3 "$@"
