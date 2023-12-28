#!/usr/bin/env sh
# shellcheck disable=SC3040,SC3043

all() {
   lint
   build
   testAll
   deploy
   show foo bar baz
}

lint() {
   _lintShellcheck
   _lintFunctionNames
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

###############################################################################
# Private
###############################################################################

# See `help set` for more information
# set -o xtrace # Uncomment to aid development
set -o errexit
set -o nounset
if set -o | grep pipefail >/dev/null; then
   set -o pipefail
fi

_SELF="$(basename "$0")"

_lintShellcheck() {
   local paths
   paths="$(find . -name \*.sh)"
   for path in $paths; do
      shellcheck "$path" || \
         _fail "$path fails shellcheck linting"
   done
}

_lintFunctionNames() {
   local builtins
   builtins="$(_listBuiltins)"
   for builtin in $builtins; do
      type "$builtin" | grep "is a shell builtin" > /dev/null || \
         _fail "$builtin function name collides with a builtin"
   done
}

_runTests() {
   local path="$1"
   local fns
   fns="$(_listTestFunctions "$path")"
   # shellcheck source=/dev/null
   . "$path"
   for fn in $fns; do
      _log "TEST: $path:$fn"
      $fn || _fail "$path:$fn"
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
   local path="${1:-./do.sh}"
   grep -E '^\s*\w+\s*\(\)\s*\{' "$path" | \
      sed -e 's/\(.*\)().*/\1/g'
}

# TODO should be shell specific
_listBuiltins() {
   cat <<EOT
alias bg break cd command continue echo eval exec exit export false fg getopts
hash help history jobs kill let local printf pwd read readonly return set shift
source test times trap true type ulimit umask unalias unset wait
EOT
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
      echo "FAILED: $msg"
   else
      echo "FAILED."
   fi
   return 1
}

_warn() {
  local msg="$1"
  echo "WARN: $msg"
}

_log() {
  local msg="$1"
  echo "$msg"
}

_testCommand() {
  command -v "$1" >/dev/null
}

_errorWithUsage() {
   local fns
   fns="$(_listPublicFunctions "$_SELF" | paste -sd '|' -)"
   printf "\nUsage:\n\t./do.sh (%s)\n" "$fns"
   return 1
}

"$@" # <- execute the task

[ "$#" -gt 0 ] || _errorWithUsage
