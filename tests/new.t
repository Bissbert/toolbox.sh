#!/bin/sh
# tools/new scaffolds leaves, nested leaves and groups.
set -eu
. "$(dirname "$0")/harness.sh"

plan 8

tmpdir="$_ROOT/.tmp-tests/new.$$"
rm -rf "$tmpdir"; mkdir -p "$tmpdir/tools"
new() { TOOLS_DIR="$tmpdir/tools" TEMPLATE_DIR="$_ROOT/templates" TOOLBOX_NAME=toolbox sh "$_ROOT/tools/new" "$@"; }

run_cmd L new ping
assert_eq 0 "$L_status" "new leaf exits 0"
[ -x "$tmpdir/tools/ping" ] && ok "leaf is executable" || not_ok "leaf is executable"
grep -q 'CMD_NAME="ping"' "$tmpdir/tools/ping" && ok "leaf has its name" || not_ok "leaf has its name"

run_cmd N new admin users list
[ -x "$tmpdir/tools/admin/users/list" ] && ok "nested leaf is created" || not_ok "nested leaf is created"

run_cmd G new --group admin
[ -x "$tmpdir/tools/admin/__main" ] && ok "group creates __main" || not_ok "group creates __main"

run_cmd D new ping
[ "$D_status" -ne 0 ] && ok "existing command is not overwritten" || not_ok "existing command is not overwritten"

run_cmd E new
[ "$E_status" -ne 0 ] && ok "missing command name is an error" || not_ok "missing command name is an error"

run_cmd U new --help
assert_match '^Usage: toolbox new' "$U_output" "help expands the program name"

rm -rf "$tmpdir"
finish
