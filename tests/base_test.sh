#!/usr/bin/env sh
# shellcheck disable=SC3040,SC3043
# See `help set` for more information
set -o xtrace
set -o errexit
set -o nounset
if set -o | grep pipefail >/dev/null; then
   set -o pipefail
fi

###############################################################################
### Show
###############################################################################
out="$(./do.sh show foo bar baz)"
test "$?" == "0"
test "$out" ==  "I am showing foo bar baz"
