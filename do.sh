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

build() {
   echo "I am building"
}

test() {
   local paths
   paths="$(find tests -name \*_test.sh)"
   for path in $paths; do
      "$path" || _fail "$path"
   done
}

deploy() {
   echo "I am deploying"
}

show() {
   echo "I am showing $1 $2 $3"
}

lint() {
   find . -name \*.sh -exec shellcheck -x {} \;
   local paths
   paths="$(find . -name \*.sh)"
   for path in $paths; do
      "$path" || _fail "$path"
   done
}

all() {
   lint
   build
   test
   deploy
   show foo bar baz
}

_listCommands() {
   # grep -E '^\s*\w+\s*\(\)\s*{' do.sh
   grep -E '^\s*\w+\s*\(\)\s*\{' "$_SELF" | \
      sed -e '/^_.*/d' -e 's/\(.*\)().*/\1/g' | sort
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
   exit 1
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

"$@" # <- execute the task

[ "$#" -gt 0 ] || printf "Usage:\n\t./do.sh %s\n" "($(_listCommands | paste -sd '|' -))"
