#!/bin/sh
# A generated project must pass its own test suite (entry 11), and the
# generator must reject bad input.
set -eu
. "$(dirname "$0")/harness.sh"

plan 14

tmpdir="$_ROOT/.tmp-tests/proj.$$"
rm -rf "$tmpdir"; mkdir -p "$tmpdir"
manifest="$tmpdir/manifest.json"
cat <<'JSON' >"$manifest"
["status", { "name": "report", "commands": ["daily", { "name": "ops", "commands": ["sync"] }] }]
JSON
dest="$tmpdir/depot"
run_cmd G $TOOL generate --name depot --manifest "$manifest" --dest "$dest"
assert_eq 0 "$G_status" "generator exits 0"

[ -f "$dest/tests/commands.t" ] && ok "tests/commands.t written" || not_ok "tests/commands.t written"
for f in cli.t generate.t hello.t; do
  [ ! -e "$dest/tests/$f" ] && ok "toolkit test $f not copied" || not_ok "toolkit test $f not copied"
done
grep -q 'bin/depot' "$dest/tests/harness.sh" && ok "harness runs bin/depot" || not_ok "harness runs bin/depot"
grep -rq 'bin/toolbox' "$dest/tests" && not_ok "no test refers to bin/toolbox" || ok "no test refers to bin/toolbox"

run_cmd R sh "$dest/tests/run"
assert_eq 0 "$R_status" "generated tests/run exits 0"
n_fail=$(printf '%s\n' "$R_output" | grep -c '^not ok' || :)
n_ok=$(printf '%s\n' "$R_output" | grep -c '^ok' || :)
assert_eq 0 "$n_fail" "generated tests have no failures"
# 1 help + 2 groups + 3 leaves x 4
assert_eq 15 "$n_ok" "generated tests cover every manifest command"

run_cmd N $TOOL generate --manifest "$manifest" --dest "$tmpdir/x"
assert_eq 2 "$N_status" "--name is required"
run_cmd B $TOOL generate --name 'bad name' --manifest "$manifest" --dest "$tmpdir/y"
assert_eq 2 "$B_status" "invalid project name is rejected"
run_cmd E $TOOL generate --name depot --manifest "$manifest" --dest "$dest"
assert_eq 2 "$E_status" "existing destination needs --force"
printf '{"not": "a list"}' > "$tmpdir/bad.json"
run_cmd J $TOOL generate --name bad --manifest "$tmpdir/bad.json" --dest "$tmpdir/bad"
[ "$J_status" -ne 0 ] && ok "manifest that is not a list fails" || not_ok "manifest that is not a list fails"

rm -rf "$tmpdir"
finish
