# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
"${sourced_233f0e8-false}" && return 0; sourced_233f0e8=true

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/embed-script.sh
. ../.lib/assert.sh
. ../.lib/test.sh
cd "$3" || exit; shift 3

test_script_embed() {
  if ! has_external_command python
  then
    echo Python is not found on path. >&2
    skip
  fi
  if is_windows && ! is_mise
  then
    echo Not in Mise env. >&2
    skip
  fi
  init_temp_dir
  if sh ./testdata/original.sh | grep -q "BEGINNING"
  then
    echo 38a0c65 >&2
    false
  fi
  local temp_sh="$TEMP_DIR"/dc691d0.sh
  embed_minified_sub ./testdata/original.sh >"$temp_sh"
  sh "$temp_sh" | grep -q "BEGINNING"

  local temp_sh2="$TEMP_DIR"/6d0f004.sh
  embed_minified_sub ./testdata/original2.sh >"$temp_sh2"
  sh "$temp_sh2" | grep -q "Version: 123.45.6"

  local temp_sh3="$TEMP_DIR/7998a1a.sh"
  embed_minified_sub ./testdata/original3.sh >"$temp_sh3"
  sh "$temp_sh3" | grep -q "hello"
}
