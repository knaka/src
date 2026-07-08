#!/usr/bin/bash
# vim: set filetype=bash tabstop=2 shiftwidth=2 expandtab :
# shellcheck shell=bash

cd "$1" || exit 1
shift
exec bash "$@"
