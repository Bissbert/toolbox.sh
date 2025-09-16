Toolbox.sh — Minimal Shell Toolsuite Framework

Overview

- Portable, POSIX sh toolsuite skeleton.
- Dispatcher + subcommands + tiny stdlib.
- No external deps beyond a POSIX shell and coreutils.

Quick Start

- Run `bin/toolbox help` to see commands.
- Add a new subcommand: copy `tools/hello` and edit.
- Generate shell completions: `bin/toolbox completion bash > /etc/bash_completion.d/toolbox` (or zsh)
- Run tests: `sh tests/run` or `make test` (pure sh)
- Install for current user: `make install-user` (installs under `~/.local/opt/toolbox` and symlinks into `~/.local/bin`)
- System install (requires sudo): `sudo make install`

Layout

- `bin/toolbox` — main dispatcher (rename to brand your suite)
- `lib/*.sh` — helpers: common, log, args, config
- `tools/*` — subcommands (executable files)
- `tests/*.t` — test files run by `tests/run`
- `tests/harness.sh` — minimal TAP-like harness used by tests
- `share/templates/subcommand` — starter template

Conventions

- Shebang `#!/bin/sh`
- One command per file in `tools/`
- Each tool supports `--help`
- Respect XDG base dirs; default to `$HOME` fallbacks

Version

- The default version is read from the `VERSION` file. You can override at runtime by exporting `TOOLBOX_VERSION`.

Completions

- `tools/completion` prints a dynamic completion script for `bash` or `zsh`.
- Bash uses a function that calls `${TOOLBOX_NAME} __commands` to list subs.
- Install example: `toolbox completion bash | sudo tee /etc/bash_completion.d/toolbox`.
- You can also generate ready-made files via `make completions` (writes to `./completions/`).

Tests

- `tests/harness.sh` is a minimal TAP-like runner in pure sh.
- `tests/*.t` import the harness, run commands, assert output & status.
- Tests isolate XDG dirs under `./.tmp-tests` to avoid system writes.
- Run all tests with `sh tests/run` or `make test`.

Makefile

- Common targets:
  - `test` — run the test suite
  - `install` — install to `/opt/toolbox` and symlink to `/usr/local/bin/toolbox`
  - `install-user` — install to `~/.local/opt/toolbox` and symlink to `~/.local/bin/toolbox`
  - `uninstall`, `uninstall-user` — remove installs and symlinks
  - `completions` — generate Bash and Zsh completion files under `./completions/`
  - `print-prefix` — show resolved install prefixes

Current State

- Minimal, working toolsuite skeleton with the following built-in commands:
  - `hello` — example command
  - `new` — scaffold a new subcommand from a template
  - `completion` — emit dynamic Bash/Zsh completion
  - `self-update` — update core files from a path or git
- Test layout consolidated under `tests/`; all tests currently pass.
- No external runtime deps beyond a POSIX shell and coreutils.

Self-Update

- `tools/self-update` supports:
  - `--from-path DIR` to sync from a local source checkout
  - `--from-git URL [--ref REF]` to fetch via git clone (if available)
  - If inside a git repo, runs a `git pull --ff-only` by default
  - `--dry-run` prints actions only
- Files updated: `bin`, `lib`, `tools`, `share`, `VERSION`, `README.md`.
