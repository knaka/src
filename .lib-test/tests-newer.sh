#!/usr/bin/env sh
# vim: set filetype=sh tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=sh
_() { eval "\${_LOADED_$1-false}" || ! eval "_LOADED_$1=true"; }; _ 83b7b83 && return

test "${_APPDIR+set}" = set || { cd "${0%[/\\]*}" 2>/dev/null || cd .; _APPDIR="$PWD"; cd "$OLDPWD" || exit; }
case "${1-}" in (_LIBDIR) cd "$2" || exit;; (*) cd "$_APPDIR" || exit;; esac; set -- "$OLDPWD" "$@";
set -- _LIBDIR ../.lib "$@"
. ../.lib/utils.sh
. ../.lib/assert.sh
. ../.lib/time.sh
. ../.lib/misc.sh
shift 2
. ./test.sh
cd "$1" || exit; shift

init_0966cde() {
  touch_time_iso --mtime="2024-02-01T12:00:00Z" "$older_dir"/965a2d4 "$older_file"
  touch_time_iso --mtime="2024-03-01T12:00:00Z" "$newer_dir"/f3d62fe "$newer_file"
}

test_newer() {
  init_temp_dir

  local older_dir="$TEMP_DIR"/d542091
  mkdir -p "$older_dir"
  local older_file="$TEMP_DIR"/232150b
  local newer_dir="$TEMP_DIR"/13c7da5
  mkdir -p "$newer_dir"
  local newer_file="$TEMP_DIR"/575e73a

  init_0966cde
  assert_true newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file"

  # Newer file in older dir.
  init_0966cde
  touch_time_iso --mtime="2024-04-01T12:00:00Z" "$older_dir"/965a2d4
  assert_false newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file"

  # Older file is newer.
  init_0966cde
  touch_time_iso --mtime="2024-04-01T12:00:00+0900" "$older_file"
  assert_false newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file"

  # Older file in newer dir.
  init_0966cde
  touch_time_iso --mtime="2024-01-01T12:00:00Z" "$newer_dir"/575e73a
  assert_false newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file"

  # Newer file is older.
  init_0966cde
  touch_time_iso --mtime="2024-01-01T12:00:00Z" "$newer_file"
  assert_false newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file"

  # A missing destination alone means "needs rebuild": true even though the
  # other, existing destination is actually newer than the sources.
  init_0966cde
  touch_time_iso --mtime="2024-04-01T12:00:00Z" "$older_dir"/965a2d4
  touch_time_iso --mtime="2024-04-01T12:00:00Z" "$older_file"
  assert_true -m 7b40b34 newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file" "$TEMP_DIR"/does_not_exist

  # Destination directory is empty.
  init_0966cde
  # shellcheck disable=SC2115
  rm -fr "$older_dir"/*
  assert_true is_dir_empty "$older_dir"
  touch_time_iso --mtime="2024-04-01T12:00:00Z" "$older_file"
  assert_true -m 27c7921 newer "$newer_dir" "$newer_file" --than "$older_dir" "$older_file"
}
