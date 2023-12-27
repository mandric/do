#!/usr/bin/env sh
# shellcheck disable=SC3040,SC3043

# See `help set` for more information
set -o xtrace
set -o errexit
set -o nounset
if set -o | grep pipefail >/dev/null; then
   set -o pipefail
fi

_SELF="$(basename "$0")"

all() {
   lint
   build
   testAll
   deploy
   show foo bar baz
}

lint() {
   local paths
   paths="$(find . -name \*.sh)"
   for path in $paths; do
      shellcheck -x "$path" || _fail "$path"
   done
}

build() {
   echo "I am building"
}

testAll() {
   local paths
   paths="$(find tests -name \*_test.sh)"
   for path in $paths; do
      _runTests "$path"
   done
}

deploy() {
   echo "I am deploying"
}

show() {
   echo "I am showing $1 $2 $3"
}

_runTests() {
   local path="$1"
   local fns
   fns="$(_listTestFunctions "$path")"
   # shellcheck source=/dev/null
   . "$path"
   for fn in $fns; do
      $fn
   done
}

_listTestFunctions() {
   local path="$1"
   _listPublicFunctions "$path" | grep ^test
}

_listPublicFunctions() {
   local path="$1"
   _listFunctions "$path" | grep -v ^_
}

_listFunctions() {
   local path="$1"
   grep -E '^\s*\w+\s*\(\)\s*\{' "$path" | \
      sed -e 's/\(.*\)().*/\1/g'
}

_hidden() {
   printf "
I am a hidden task and won't appear in the usage desciption because I start with
an _ (underscore). If you know me you can still call me directly.
"
}

_fail() {
   local msg="$1"
   if [ -n "$msg" ]; then
      echo "Failed: $msg"
   else
      echo "Failed."
   fi
   return 1
}

_warn() {
  local msg="$1"
  echo "Warning: $msg"
}

_log() {
  local msg="$1"
  echo "Log: $msg"
}

_testCommand() {
  command -v "$1" >/dev/null
}

_printUsage() {
   local fns
   fns="$(_listPublicFunctions "$_SELF" | paste -sd '|' -)"
   printf "\nUsage:\n\t./do.sh %s\n" "($fns)"
}

"$@" # <- execute the task

[ "$#" -gt 0 ] || _printUsage
