#!/usr/bin/env sh

# Code generated from "tasks-project.sh" by tasks:expand task. DO NOT EDIT.

#marker ed9038b1-9de5-40fd-bede-eabed9b60306
#MISE description="Convert JSON object to shell variable assignment expressions."
saved_pwd_474b89b="$PWD"
_APPDIR="$MISE_PROJECT_ROOT"/mise-tasks
cd "$_APPDIR"
. ./"tasks-project.sh"
cd "$saved_pwd_474b89b"
set -o nounset -o errexit
task_json2sh "$@"
