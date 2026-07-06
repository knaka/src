# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { case "${_ids-}" in (*$1*) ;; (*) _ids="$1,${_ids-}"; false;; esac; }; _ 9eabbaf && return 0

rc_test_skipped=10

should_run_fulltest_80e79eb=false

# Skip this test unless full test is being run.
skip_unless_full() {
  if $should_run_fulltest_80e79eb
  then
    return 0
  fi
  return "$rc_test_skipped"
}

skip() {
  return "$rc_test_skipped"
}

skip_if() {
  if "$@"
  then
    return "$rc_test_skipped"
  fi
}

skip_unless() {
  if ! "$@"
  then
    return "$rc_test_skipped"
  fi
}
