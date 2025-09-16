#!/bin/sh
# Minimal pure-sh test harness (TAP-like output)
set -eu

_ROOT=${_ROOT:-"$(CDPATH= cd -- "$(dirname -- "$0")"/.. && pwd -P)"}

# Isolated XDG dirs inside the repo to avoid system writes
export XDG_CONFIG_HOME="$_ROOT/.tmp-tests/config"
export XDG_DATA_HOME="$_ROOT/.tmp-tests/data"
export XDG_CACHE_HOME="$_ROOT/.tmp-tests/cache"
mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_CACHE_HOME"

TOOL=${TOOL:-"sh $_ROOT/bin/toolbox"}

_tests=0; _failed=0; _plan=0

plan() { _plan=$1; echo "1..$1"; }
ok() { _tests=$(( _tests + 1 )); echo "ok $_tests - $*"; }
not_ok() { _tests=$(( _tests + 1 )); _failed=$(( _failed + 1 )); echo "not ok $_tests - $*"; }

assert_eq() {
  exp=$1; got=$2; msg=${3:-}
  [ "$got" = "$exp" ] && ok "$msg" || { echo "  ---"; echo "    expected: $exp"; echo "    got:      $got"; echo "  ..."; not_ok "$msg"; }
}

assert_match() {
  pat=$1; got=$2; msg=${3:-}
  printf '%s' "$got" | grep -E "$pat" >/dev/null 2>&1 && ok "$msg" || { echo "  ---"; echo "    pattern: $pat"; echo "    got:     $got"; echo "  ..."; not_ok "$msg"; }
}

run_cmd() {
  # Usage: run_cmd <var_prefix> <command...>
  _var=$1; shift
  _out_file="$_ROOT/.tmp-tests/out.$$"
  set +e
  "$@" >"$_out_file" 2>&1
  _st=$?
  set -e
  _out=$(cat "$_out_file")
  rm -f "$_out_file"
  eval "${_var}_status=$_st"
  esc=$(printf %s "$_out" | sed "s/'/'\\''/g")
  eval "${_var}_output='${esc}'"
}

finish() {
  if [ "$_failed" -gt 0 ]; then exit 1; fi
}
