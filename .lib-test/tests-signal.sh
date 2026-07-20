#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 2a7399c && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
shift 2
cd "$1" || exit; shift

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
