#!/bin/bash
set -o nounset -o errexit -o pipefail

echo My name is "${BASH_SOURCE[0]}".
for hex in "$@"
do
  echo Arg: "$hex"
done

perl -e 'printf("Hello, %s from Perl.\n", "MSYS")'
