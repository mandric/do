#!/usr/bin/env sh

testUsageOutput() {
  local out
  local expected
  out="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh
  )"
  expected="$(
    printf "\nUsage:\n\t./do.sh (all|lint|build|testAll|deploy|show)\n"
  )"
  test "$out" == "$expected"
}

testReturnVal() {
  docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh deploy
  test "$?" == "0"
}

testFailureMessage() {
  out="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh _fail foo || printf "foo failed"
  )"
  test "$out" == "$(printf "Failed: foo\nfoo failed")"
}