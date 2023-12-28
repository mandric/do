#!/usr/bin/env sh

testUsageOutput() {
  local stdout
  local expected
  stdout="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh || :
  )"
  expected="$(
    printf "\nUsage:\n\t./do.sh (all|lint|build|testAll|deploy|show|todos)\n"
  )"
  test "$stdout" == "$expected"
}

testSuccess() {
  docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh deploy
  test $? == 0
}

testFailureMessage() {
  local stdout
  stdout="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh _fail foo || :
  )"
  test "$stdout" == "$(printf "FAILED: foo")"
}