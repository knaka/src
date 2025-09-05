#!/bin/sh
set -o nounset -o errexit

test "${guard_7917aa0+set}" = set && return 0; guard_7917aa0=-

. ./task.sh

set_sync_ignored_bcc0a9f() (
  for dir in gradle/wrapper .gradle app/build .kotlin
  do
    mkdir -p "$dir"
    set_sync_ignored "$dir"
  done

  set_sync_ignored "$SCRIPT_DIR"/gradlew || :
  set_sync_ignored "$SCRIPT_DIR"/gradlew.bat || :
)

set_sync_ignored_bcc0a9f

gradle_home() (
  # Gradle | Releases https://gradle.org/releases/
  ver="8.10"

  bin_dir_path="$HOME/.bin"
  GRADLE_HOME=${GRADLE_HOME:-$bin_dir_path/gradle-${ver}}
  if ! test -d "$GRADLE_HOME"
  then
    mkdir -p "$bin_dir_path"
    temp_dir_path=$(mktemp -d)
    zip_path="$temp_dir_path"/temp.zip
    curl --location -o "$zip_path" "https://services.gradle.org/distributions/gradle-${ver}-bin.zip"
    (
      cd "$bin_dir_path" || exit 1
      unzip -q "$zip_path"
    )
    chmod +x "$GRADLE_HOME"/bin/gradle"$(exe_ext)"
  fi
  echo "$GRADLE_HOME"
)

set_gradle_env() {
  set_java_env
  GRADLE_HOME="$(gradle_home)"
  export GRADLE_HOME
  PATH="$GRADLE_HOME"/bin:"$PATH"
  export PATH
}

subcmd_gradle() ( # Runs gradle command.
  chdir_script
  set_gradle_env
  cross_run "$GRADLE_HOME"/bin/gradle "$@"
)

subcmd_build() (
  chdir_script
  if ! newer ./app/src --than ./app/build
  then
    return 0
  fi
  subcmd_gradle build "$@"
)

subcmd_gradle_wrapper() (
  chdir_script
  subcmd_gradle wrapper "$@"
  set_sync_ignored_bcc0a9f 
)