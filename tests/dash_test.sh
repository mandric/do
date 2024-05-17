#!/usr/bin/env sh

testUsageOutput() {
  local stdout
  local expected
  expected="$(
    printf "\nUsage:\n\t./do.sh (all|lint|build|testAll|deploy|show|todos)\n"
  )"
  stdout="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh || :
  )"
  test "$stdout" == "$expected"
}

testSuccess() {
  docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh deploy
  test $? == 0
}

testFailure() {
  local stdout
  stdout="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh _fail foo || :
  )"
  test "$stdout" == "$(printf "FAILED: foo")"
}