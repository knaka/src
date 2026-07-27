#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 2a7399c && return

# shellcheck disable=SC3028,SC3054
if test "${BASH_VERSION+set}"; then cd "${BASH_SOURCE[0]%[/\\]*}" || cd .; elif test "${1-}" = SCRIPTDIR; then cd "$2" || exit; else cd "${0%[/\\]*}" || cd .; fi 2>/dev/null; set -- SCRIPTDIR ../.lib "$OLDPWD" "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
cd "$3" || exit; shift 3

handler_d92d23a() { :; }
handler_e9f2923() { :; }
handler_39181ea() { :; }

test_term_signal() {
  add_term_handler handler_d92d23a
  assert_failure add_signal_handler handler_e9f2923 TERM HOGE
  add_signal_handler handler_e9f2923 TERM EXIT
  add_term_handler handler_e9f2923
  assert_eq "$TERM_cmds_054cf7c" "handler_e9f2923;handler_d92d23a;:"
  (
    # Trap handler and handler statements are reset in subshell.
    add_term_handler handler_39181ea
    assert_eq "$TERM_cmds_054cf7c" "handler_39181ea;:"
  )
  remove_term_handler handler_e9f2923
  assert_eq "$TERM_cmds_054cf7c" "handler_d92d23a;:"
  remove_term_handler handler_d92d23a
  assert_eq "$TERM_cmds_054cf7c" ":"
}
