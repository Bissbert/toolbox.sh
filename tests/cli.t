#!/bin/sh
set -eu
. "$(dirname "$0")/harness.sh"

plan 5

run_cmd H $TOOL help
assert_match 'Commands:' "$H_output" "help shows commands header"
assert_match '\bhello\b' "$H_output" "help lists hello"

run_cmd C $TOOL __commands
assert_match '^hello$' "$C_output" "__commands includes hello"
assert_match '^new$' "$C_output" "__commands includes new"

finish
