#!/usr/bin/env sh
# shellcheck disable=SC3040,SC3043
# See `help set` for more information
set -o xtrace
set -o errexit
set -o nounset
if set -o | grep pipefail >/dev/null; then
   set -o pipefail
fi

usageOutput="$(printf "Usage:\n\t./do.sh (all|build|deploy|lint|show|test)\n")"

###############################################################################
### Ash
###############################################################################
out="$(
  docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh
)"
test "$out" == "$usageOutput"

docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh deploy

out="$(
  docker run --rm -v "$(pwd)/do.sh:/do.sh" alpine ash /do.sh _fail foo || printf "foo failed"
)"
test "$out" == "$(printf "Failed: foo\nfoo failed")"

###############################################################################
### Dash
###############################################################################
out="$(
  docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh
)"
test "$out" == "$usageOutput"

docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh deploy

out="$(
  docker run --rm -v "$(pwd)/do.sh:/do.sh" ubuntu dash /do.sh _fail foo || printf "foo failed"
)"
test "$out" == "$(printf "Failed: foo\nfoo failed")"

# expect="$(printf "Usage:\n\t./do.sh (all|build|deploy|test)\n")"
# test "$out" == "$expect"

# script="$(cat do.sh)"
# docker run --rm bash bash -c "$script"
# docker run --init --rm alpine ash -c "$script"
# echo ret $?
# docker run --rm ubuntu dash -c "$script"
# docker run --rm alpine ash -c 'apk add mksh >/dev/null && mksh -c "$1"' - "$script"
# docker run --rm alpine ash -c 'apk add zsh >/dev/null && zsh -c "$1"' - "$script"