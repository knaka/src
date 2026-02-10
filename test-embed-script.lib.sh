# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_233f0e8-false}" && return 0; sourced_233f0e8=true

set -- "$PWD" "$@"; if test "${2:+$2}" = _LIBDIR; then cd "$3" || exit 1; fi
set -- _LIBDIR . "$@"
. ./embed-script.lib.sh
. ./assert.lib.sh
shift 2
cd "$1" || exit 1; shift

test_script_embed() {
  if sh ./testdata/original.sh | grep -q "BEGINNING"
  then
    false
  fi
  local temp_sh="$TEMP_DIR"/dc691d0.sh
  embed_minified_sub ./testdata/original.sh >"$temp_sh"
  sh "$temp_sh" | grep -q "BEGINNING"
}
