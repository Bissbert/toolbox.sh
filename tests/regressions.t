#!/bin/sh
# Regression checks for previously fixed bugs. The numbers label each bug;
# the generated project's own suite (issue #5) is in generated.t, and check 12
# covers issue #6.
set -eu
. "$(dirname "$0")/harness.sh"

plan 13

tmpdir="$_ROOT/.tmp-tests/reg.$$"
rm -rf "$tmpdir"; mkdir -p "$tmpdir"

# 1. executable entry points
[ -x "$_ROOT/bin/toolbox" ] && [ -x "$_ROOT/tools/generate" ] && [ -x "$_ROOT/templates/project/bin/toolbox" ] \
  && ok "1. entry points are executable" || not_ok "1. entry points are executable"

# 3. the template's lib/config.sh is not ignored
if command -v git >/dev/null 2>&1 && git -C "$_ROOT" rev-parse >/dev/null 2>&1; then
  if git -C "$_ROOT" check-ignore -q --no-index templates/project/lib/config.sh; then
    not_ok "3. templates/project/lib/config.sh is not ignored"
  else ok "3. templates/project/lib/config.sh is not ignored"; fi
else
  ok "3. templates/project/lib/config.sh is not ignored # SKIP no git checkout"
fi

# 4. discovery does not rely on GNU find -printf
grep -rq -- '-printf' "$_ROOT/bin" "$_ROOT/lib" && not_ok "4. no find -printf" || ok "4. no find -printf"

# 5. positional arguments reach the leaf
run_cmd P $TOOL hello Alice
assert_match 'Hello, Alice!' "$P_output" "5. positional argument reaches hello"

# 7. tools/new parses under sh
sh -n "$_ROOT/tools/new" && ok "7. tools/new parses" || not_ok "7. tools/new parses"

# 8. __all_commands works under sh
run_cmd A sh "$_ROOT/bin/toolbox" __all_commands
assert_match '^hello$' "$A_output" "8. __all_commands under sh"

# 2, 6, 9, 10 need a generated project with a nested command.
printf '[{"name": "report", "commands": ["daily"]}]' > "$tmpdir/m.json"
$TOOL generate --name depot --manifest "$tmpdir/m.json" --dest "$tmpdir/depot" >/dev/null 2>&1
[ -f "$tmpdir/depot/lib/config.sh" ] && ok "2. generated project has lib/config.sh" || not_ok "2. generated project has lib/config.sh"
run_cmd D sh "$tmpdir/depot/bin/depot" report daily
assert_match 'report daily is not implemented yet' "$D_output" "6. nested command sources its project root"
run_cmd H sh "$tmpdir/depot/bin/depot" report daily --help
printf '%s' "$H_output" | grep -q '\${' && not_ok "9. generated help has no literal \${...}" || ok "9. generated help has no literal \${...}"
assert_match '^Usage: depot report daily' "$H_output" "9. generated usage names the project"
assert_match '^  depot report daily$' "$H_output" "10. generated examples name the project"

# 12. built-in command help names the program
out=""
for c in new completion generate; do out="$out$($TOOL $c --help 2>&1)"; done
out="$out$($TOOL hello --help 2>&1)"
printf '%s' "$out" | grep -q '\${' && not_ok "12. built-in help has no literal \${...}" || ok "12. built-in help has no literal \${...}"
run_cmd W sh "$tmpdir/depot/bin/depot" new --help
assert_match '^Usage: depot new' "$W_output" "12. generated project's new --help names the project"

rm -rf "$tmpdir"
finish
