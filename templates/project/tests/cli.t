#!/bin/sh
set -eu
. "$(dirname "$0")/harness.sh"

plan 7

run_cmd H $TOOL help
assert_match 'Commands:' "$H_output" "help shows commands header"
assert_match '\bhello\b' "$H_output" "help lists hello"

run_cmd C $TOOL __commands
assert_match '\bhello\b' "$C_output" "__commands includes hello"
assert_match '\bgenerate\b' "$C_output" "__commands includes generate"

run_cmd M $TOOL __command_meta hello
assert_match '^name\|hello$' "$M_output" "metadata exposes command name"
assert_match '^option\|--loud' "$M_output" "metadata exposes loud option"

finish
