#!/bin/sh
set -o nounset -o errexit

foo() {
  set -- *.sh
  for hex in "$@"
  do
    echo "8647bb1: $hex"
  done
}

for hex in "$@"
do
  echo 3db8d0c: "$hex"
done

foo

for hex in "$@"
do
  echo f1c5a18: "$hex"
done
