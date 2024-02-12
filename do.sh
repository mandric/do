#!/usr/bin/env sh

all() {
   lint
   build
   testAll
   deploy
   show foo bar baz
   todos
}

lint() {
   _lintShellcheck
   _lintFunctionNames
}

build() {
   echo "I am building"
}

# TODO test examples
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

todos() {
   git grep --color TODO | sed '/git grep .*/d'
}

###############################################################################
# Private
###############################################################################

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
   cat <<EOT
I am a hidden task and won't appear in the usage desciption because I start with
an _ (underscore). If you know me you can still call me directly.
EOT
}

_fail() {
   local msg="$1"
   if [ -n "$msg" ]; then
     _log "FAILED: $msg"
   else
     _log "FAILED."
   fi
   return 1
}

_warn() {
  local msg="$1"
  _log "WARN: $msg"
}

_log() {
  local msg="$1"
  echo "$msg" >&2
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

_SELF="$(basename "$0")"
_QUIET=false

# See `help set` for more information
(set -o pipefail) 2>/dev/null || _warn "pipefail not supported."
set -o errexit
set -o nounset

[ "$#" -gt 0 ] || _errorWithUsage

if [ "$1" = "-q" ]; then
  _QUIET=true
  set +o xtrace
  shift
fi

if [ "$1" != "_listCommands" ]; then
  # Do not print commands when doing tab completion.
  if [ $_QUIET = false ]; then
    set -o xtrace
  fi
fi

"$@" # execute the task
