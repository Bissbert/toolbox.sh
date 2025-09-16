Toolbox.sh — Minimal Shell Toolsuite Framework

Overview

- Portable, POSIX sh toolsuite skeleton.
- Dispatcher + subcommands + tiny stdlib.
- No external deps beyond a POSIX shell and coreutils.

Quick Start

- Run `bin/toolbox help` to see commands.
- Add a new subcommand: copy `tools/hello` and edit.
- Generate shell completions: `bin/toolbox completion bash > /etc/bash_completion.d/toolbox` (or zsh)
- Run tests: `sh test/run` (pure sh)

Layout

- `bin/toolbox` — main dispatcher (rename to brand your suite)
- `lib/*.sh` — helpers: common, log, args, config
- `tools/*` — subcommands (executable files)
- `tests/*.t` — test files run by `test/run`
- `share/templates/subcommand` — starter template

Conventions

- Shebang `#!/bin/sh`
- One command per file in `tools/`
- Each tool supports `--help`
- Respect XDG base dirs; default to `$HOME` fallbacks

Version

- Set in `bin/toolbox` as `TOOLBOX_VERSION`

Completions

- `tools/completion` prints a dynamic completion script for `bash` or `zsh`.
- Bash uses a function that calls `${TOOLBOX_NAME} __commands` to list subs.
- Install example: `toolbox completion bash | sudo tee /etc/bash_completion.d/toolbox`.

Tests

- `test/harness.sh` is a minimal TAP-like runner in pure sh.
- `tests/*.t` import the harness, run commands, assert output & status.
- Tests isolate XDG dirs under `./.tmp-tests` to avoid system writes.

Self-Update

- `tools/self-update` supports:
  - `--from-path DIR` to sync from a local source checkout
  - `--from-git URL [--ref REF]` to fetch via git clone (if available)
  - If inside a git repo, runs a `git pull --ff-only` by default
  - `--dry-run` prints actions only
- Files updated: `bin`, `lib`, `tools`, `share`, `VERSION`, `README.md`.
