[← back to the overview](../README.md)

# How this was measured

Every result in the overview comes from one script run in a Linux container:

```sh
sh devtools/linux-run.sh > media/captures/linux-run.txt
```

[`devtools/linux-run.sh`](../devtools/linux-run.sh) starts
`python:3.12-slim-bookworm`, installs `git`, mounts the repository read-only
and copies it with its history. It then runs
[`devtools/measure.py`](../devtools/measure.py), a check for each entry in
[Bugs found](BUGS-FOUND.md), the test suite under `dash` and `bash`, and the
test suite of a freshly generated project. The full output is
[`media/captures/linux-run.txt`](../media/captures/linux-run.txt); every block
below is taken from it.

## Environment

| | |
|---|---|
| Kernel | Linux 6.5.11-linuxkit, aarch64 (Docker Desktop VM) |
| Image | `python:3.12-slim-bookworm` (`sha256:392307d2…23564e`) |
| Shells | `/bin/sh` is `dash`; GNU bash 5.2.15 |
| Tools | git 2.39.5, Python 3.12.14 |
| Commit | `4b13dec` |
| Date | 2026-09-24 |

```mermaid
flowchart LR
    S["repository copy"] --> M["devtools/measure.py"]
    S --> B["per-bug checks"]
    S --> T["tests/run<br/>dash and bash"]
    S --> G["generate depot"]
    G --> GC["depot help, report daily,<br/>new --group"]
    G --> GT["depot tests/run"]

    style S fill:#1f6feb,stroke:#58a6ff,color:#fff
    style G fill:#9e6a03,stroke:#d29922,color:#fff
    style GT fill:#238636,stroke:#3fb950,color:#fff
```

## `devtools/measure.py`

```text
revision    4b13dec
tracked_files    61
tracked_executable_files    26
version_rc    0
version_output    toolbox 0.1.0
help_rc    0
help_commands    5
direct_version_rc    0
direct_version_output    toolbox 0.1.0
tests_rc    0
tests_ok    55
tests_not_ok    0
config_ignore_rc    1
config_ignore_output
scratch_help_rc    0
scratch_help_commands    5
scratch_hello_rc    0
scratch_hello_output    toolbox: Hello, Alice!
scratch_generate_rc    0
scratch_generate_output    toolbox: Copying skeleton into <scratch>/depot\ndepot: created status\ntoolbox: Project 'depot' generated at <scratch>/depot
```

`config_ignore_rc` is `1` because `git check-ignore` no longer matches
`templates/project/lib/config.sh`. The scratch probe runs from a `git archive`
of `HEAD`, so it does not depend on the modes in the working copy.

## The top-level toolbox

| Check | Result |
|---|---|
| Tracked modes | 35 × `100644`, 26 × `100755` |
| `./bin/toolbox --version` | `toolbox 0.1.0`, exit `0` |
| `./bin/toolbox help` | lists `completion`, `generate`, `hello`, `new`, `self-update` |
| `USER=nobody ./bin/toolbox hello Alice` | `toolbox: Hello, Alice!` |
| `sh bin/toolbox __all_commands` under `dash` | the same five commands, exit `0` |
| `sh tests/run` (`dash`) | exit `0`, 55 ok, 0 not ok |
| `bash tests/run` | exit `0`, 55 ok, 0 not ok |
| `./bin/toolbox new --help` | `Usage: toolbox new [--group] <command> [subcommand ...]` ([entry 12](BUGS-FOUND.md)) |
| `./bin/toolbox hello --help` | `Examples:` / `toolbox hello`, `toolbox hello Alice --loud` |

## A generated project

The README's manifest, `["status", {"name": "report", "commands": ["daily"]}]`,
generates `depot`:

```text
toolbox: Copying skeleton into <scratch>/depot
depot: created status
depot: created report/daily
depot: created report/__main
toolbox: Project 'depot' generated at <scratch>/depot
exit=0
```

`depot/lib/` holds `args.sh`, `cmd.sh`, `common.sh`, `config.sh` and `log.sh`.

| Check | Result |
|---|---|
| `./bin/depot help` | starts `depot 0.1.0`; lists `completion`, `new`, `report`, `self-update`, `status` |
| `./bin/depot report daily --help` | usage, options, and `Examples:` / `depot report daily` |
| `./bin/depot report daily` | `depot: report daily is not implemented yet`, exit `0` |
| `./bin/depot new --group demo` | `depot: created demo/__main`; `help` then lists `demo` |
| `./bin/depot new --help` | `Usage: depot new [--group] <command> [subcommand ...]` |
| `sh tests/run` | exit `0`, 10 ok, 0 not ok ([entry 11](BUGS-FOUND.md)) |

`depot/tests/` holds `commands.t`, `harness.sh` and `run`. The harness targets
`bin/depot`, and `commands.t` is written from the manifest: one check of
`help`, one `__all_commands` check per group and leaf, and for each leaf a
`--help` exit, a `Usage: depot <path>` line and a stub run. Before the fix the
project got the template's `cli.t` and `generate.t`, which called
`bin/toolbox` and failed all 14 assertions.

## Not covered

- macOS. Entries 4 and 7 were macOS-only failures. The Linux run shows that
  the new code works under `dash` and `bash`, but it does not re-run the macOS
  shell or BSD `find`.
- `make install`, the Debian package in `packaging/deb/`, `self-update` and
  shell completion installed into a real shell.
- No terminal session was recorded. The diagrams in the other write-ups
  explain the source; they are not recordings.
