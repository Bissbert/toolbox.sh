# Toolbox.sh — POSIX CLI Toolkit & Generator

Toolbox.sh is a batteries-included framework for building Git-style command suites in pure POSIX shell. It combines a flexible dispatcher, reusable libraries, metadata-driven help output, and a JSON-powered project generator so you can spin up fully tested CLIs without leaving `/bin/sh`.

## Highlights
- **Portable by default** – every script targets `sh`, avoiding bashisms and external dependencies.
- **Structured subcommands** – directories map to namespaces, with `__main` entry points for groups.
- **Metadata-aware UX** – populate `CMD_*` fields once and gain uniform `--help` output plus Bash/Zsh completion.
- **Generator included** – feed a manifest to `bin/toolbox generate` and get a ready-to-run project with tests and templates.

## Prerequisites
- POSIX shell and coreutils (standard on Linux/macOS).
- `python3` for manifest parsing and templating.
- Optional: `git` for `tools/self-update --from-git`.

## Quick Start
```sh
# Inspect built-in commands
bin/toolbox help

# Describe your command tree
cat >manifest.json <<'JSON'
[
  "status",
  { "name": "release", "commands": [
    "plan",
    { "name": "deploy", "commands": ["canary", "prod"] }
  ] }
]
JSON

# Generate a project in ./demo
bin/toolbox generate --name demo --manifest manifest.json --dest ./demo

# Add logic, then run the tests
cd demo
sh tests/run
```

## Command Overview
| Command | Purpose |
| --- | --- |
| `hello` | Example leaf command wiring `lib/cmd.sh` metadata. |
| `new` | Scaffold a leaf or group command (`tools/new analytics cohort`). |
| `generate` | Create a full project from a JSON manifest. |
| `completion` | Emit dynamic Bash/Zsh completion informed by command metadata. |
| `self-update` | Sync the framework from a local path or git remote. |

## Project Layout
```
bin/toolbox          # Dispatcher / entry point
lib/                 # Shared helpers (common.sh, log.sh, args.sh, config.sh, cmd.sh)
templates/command/   # Leaf/group stubs used by `tools/new` and the generator
templates/project/   # Skeleton copied into new projects (docs, tests, tooling)
tools/               # Built-in commands
tests/               # TAP-style test suite (`tests/run` harness)
docs/                # External-ready documentation (guide + gist)
```

## Development Workflow
1. Make changes and keep metadata current in each command (`CMD_SUMMARY`, `CMD_OPTIONS`, etc.).
2. Run `sh tests/run` (or `make test`) to exercise CLI behaviour and generator scenarios.
3. Regenerate completions when option sets change: `bin/toolbox completion bash > completions/toolbox.bash`.
4. Document changes in `docs/` and `AGENTS.md` so downstream projects stay aligned.

## Installing Locally
- `make install-user` → installs under `~/.local/opt/toolbox` and symlinks into `~/.local/bin`.
- `sudo make install` → installs under `/opt/toolbox` with a `/usr/local/bin/toolbox` shim.
- `make completions` → writes Bash/Zsh completion scripts to `./completions/`.

## Documentation
- [docs/GENERATOR_GUIDE.md](docs/GENERATOR_GUIDE.md) — copy-ready README describing the generator workflow.
- [docs/GENERATOR_GIST.md](docs/GENERATOR_GIST.md) — condensed quickstart for sharing as a gist or snippet.
- [AGENTS.md](AGENTS.md) — contributor playbook covering style, testing, and PR expectations.

## Troubleshooting
- **Missing python3** → install via your package manager (`apt install python3`, `brew install python`).
- **Manifest validation errors** → confirm the JSON array structure and ensure every group has a `commands` array.
- **Permission issues** → prefer `make install-user` or run privileged commands with care.

## Contributing
Follow the guidelines in `AGENTS.md`: keep commits focused, ensure tests pass, update docs/templates when behaviour changes, and include reproduction commands in PR descriptions.
