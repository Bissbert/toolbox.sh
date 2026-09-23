#!/bin/sh
set -eu
. "$(dirname "$0")/harness.sh"

plan 8

tmpdir="$_ROOT/.tmp-tests/gen.$$"
mkdir -p "$tmpdir"
manifest="$tmpdir/manifest.json"
cat <<'JSON' >"$manifest"
[
  "status",
  { "name": "release", "commands": [
    "plan",
    { "name": "deploy", "commands": ["canary", "prod"] }
  ] }
]
JSON

dest="$tmpdir/demo"
run_cmd G $TOOL generate --name demo --manifest "$manifest" --dest "$dest" --force
assert_eq 0 "$G_status" "generator exits cleanly"
assert_match "Project .*demo.* generated" "$G_output" "generator reports success"

[ -f "$dest/bin/demo" ] && ok "binary renamed" || not_ok "binary renamed"
[ -f "$dest/tools/status" ] && ok "leaf command scaffolded" || not_ok "leaf command scaffolded"
[ -f "$dest/tools/release/plan" ] && ok "nested leaf scaffolded" || not_ok "nested leaf scaffolded"
[ -f "$dest/tools/release/__main" ] && ok "group command created" || not_ok "group command created"

run_cmd C sh "$dest/bin/demo" __commands release
a=$(printf '%s' "$C_output")
printf '%s' "$a" | grep -Eq '\bplan\b' && ok "release lists plan" || not_ok "release lists plan"
printf '%s' "$a" | grep -Eq '\bdeploy\b' && ok "release lists deploy" || not_ok "release lists deploy"

finish
