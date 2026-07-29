#!/usr/bin/env bash

set -o nounset -o errexit -o pipefail

false && true
echo $? # “1”

false || false
echo $? # Not reached.
