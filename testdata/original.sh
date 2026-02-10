#!/usr/bin/env sh

script='BEGIN { print "hello" }' #EMBED: ./foobar.awk

awk \
  "$script" \
  </dev/null
