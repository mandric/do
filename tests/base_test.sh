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

testHidden() {
  local stdout
  stdout="$(./do.sh _hidden)"
  test $? == 0
  echo "$stdout" | grep "I am a hidden task"
  test $? == 0
}