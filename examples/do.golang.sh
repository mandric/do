#!/usr/bin/env sh
# shellcheck disable=SC3040,SC3043
# Do - The Simplest Build Tool on Earth.
# Documentation and examples see https://github.com/8gears/do

# See `help set` for more information
# set -o xtrace # Uncomment to aid development
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

###############################################################################
# Private
###############################################################################

_SELF="$(basename "$0")"

_listPublicFunctions() {
   local path="${1:-./do.sh}"
   _listFunctions "$path" | grep -v ^_
}

_listFunctions() {
   local path="${1:-./do.sh}"
   grep -E '^\s*\w+\s*\(\)\s*\{' "$path" | \
      sed -e 's/\(.*\)().*/\1/g'
}

"$@" # <- execute the task

[ "$#" -gt 0 ] || printf "Usage:\n\t./do.sh %s\n" "($(_listPublicFunctions "$_SELF" | paste -sd '|' -))"