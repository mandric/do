#!/usr/bin/env sh

testShowOutput() {
  local out
  out="$(./do.sh show foo bar baz)"
  test "$out" ==  "I am showing foo bar baz"
}

testShowRetval() {
  ./do.sh show foo bar baz > /dev/null
  test "$?" == "0"
}
