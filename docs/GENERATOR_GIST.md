# toolbox.sh Generator Quickstart

Spin up a nested POSIX CLI in under a minute.

```sh
# 1. Describe your command tree
cat >manifest.json <<'JSON'
[
  "status",
  { "name": "release", "commands": [
    "plan",
    { "name": "deploy", "commands": ["canary", "prod"] }
  ] }
]
JSON

# 2. Generate the project (dispatcher becomes ./demo/bin/demo)
bin/toolbox generate --name demo --manifest manifest.json --dest ./demo

# 3. Inspect and run the suite
cd demo
ls tools
sh tests/run
```

### Manifest Cheatsheet
- Root is a JSON array.
- String → leaf command (`"status"`).
- Object → command group `{ "name": "deploy", "commands": [...] }`.
- Nest as deep as needed; directories + `__main` files appear automatically.

### Metadata Reminders
Each generated script includes placeholders for:
- `CMD_USAGE`, `CMD_SUMMARY`, `CMD_DESCRIPTION`
- `CMD_OPTIONS` (format: `--flag|VALUE|Description`)
- `CMD_EXAMPLES`
- `CMD_SUBCOMMANDS` (group `__main` only)
Fill these in as you add behaviour so `--help` and completion scripts stay correct.

### Layout Snapshot
- `bin/<name>` — dispatcher that resolves nested commands.
- `lib/` — helpers for logging, args, config, metadata.
- `templates/command/` — stubs consumed by `bin/<name> new ...`.
- `docs/` — copy of this quickstart + full guide; customise before publishing.
- `tests/` — TAP harness (`tests/run`) and example specs; add one per command.

### Common Follow-ups
- `bin/<name> help` — inspect command tree & usage from metadata.
- `bin/<name> new analytics cohort` — scaffold another nested command.
- `bin/<name> completion bash` — regenerate completion script after tweaking metadata.
- `make test` — optional convenience wrapper around `sh tests/run`.

Need more detail? Drop `docs/GENERATOR_GUIDE.md` into your repo as the README.
