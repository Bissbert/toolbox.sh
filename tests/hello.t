#!/bin/sh
set -eu
. "$(dirname "$0")/harness.sh"

plan 4

run_cmd R $TOOL hello
assert_match '^toolbox: Hello, .+!$' "$R_output" "hello default name"
assert_eq 0 "$R_status" "hello exit status"

run_cmd L $TOOL hello --loud test
assert_match '^toolbox: HELLO, TEST!$' "$L_output" "hello loud"
assert_eq 0 "$L_status" "hello loud status"

finish
