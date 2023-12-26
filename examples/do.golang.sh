#!/usr/bin/env sh
# shellcheck disable=SC3040,SC3043
# Do - The Simplest Build Tool on Earth.
# Documentation and examples see https://github.com/8gears/do

# See `help set` for more information
set -o xtrace
set -o errexit
set -o nounset
if set -o | grep pipefail >/dev/null; then
   set -o pipefail
fi

build() {
   dep ensure || go get -u github.com/golang/dep/cmd/dep && dep ensure
   go vet
   go build
}

install() {
   go install
}

test() {
   go test .
}

all() {
   build && install && test
}

_listCommands() {
   grep -E '^\s*\w+\s*\(\)\s*\{' "$_SELF" | \
      sed -e '/^_.*/d' -e 's/\(.*\)().*/\1/g' | sort
}

"$@" # <- execute the task

[ "$#" -gt 0 ] || printf "Usage:\n\t./do.sh %s\n" "($(_listCommands | paste -sd '|' -))"
