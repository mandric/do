#!/usr/bin/env sh

testUsageOutput() {
  local stdout
  local expected
  stdout="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu bash /do.sh || :
  )"
  expected="$(
    printf "\nUsage:\n\t./do.sh (all|lint|build|testAll|deploy|show)\n"
  )"
  test "$stdout" == "$expected"
}

testSuccess() {
  docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu bash /do.sh deploy
  test $? == 0
}

testFailure() {
  local stdout
  stdout="$(
    docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu bash /do.sh _fail foo || :
  )"
  test "$stdout" == "$(printf "FAILED: foo")"
}