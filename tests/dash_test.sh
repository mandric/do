#!/usr/bin/env sh

testUsageOutput() {
  local out
  local expected
  out="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh
  )"
  expected="$(
    printf "\nUsage:\n\t./do.sh (all|lint|build|testAll|deploy|show)\n"
  )"
  test "$out" == "$expected"
}

testSuccess() {
  docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh deploy
  test "$?" == "0"
}

testFailure() {
  out="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh _fail foo || printf "foo failed"
  )"
  test "$out" == "$(printf "Failed: foo\nfoo failed")"
}