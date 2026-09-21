[← back to the overview](../README.md)

# Measurement and provenance

This pass reports the reverted checkout, not a repaired copy. The only
measurement runner committed for the pass is
[`devtools/measure.py`](../devtools/measure.py). It uses Python's standard
library, runs the shell commands directly, and uses a temporary `git archive`
when a source-path probe needs executable permissions. Permissions are changed
only in that temporary archive.

```mermaid
flowchart LR
    S["current checkout"] --> V["version and help probes"]
    S --> T["tracked mode and ignore probes"]
    S --> R["tests/run"]
    S --> A["temporary git archive"]
    A --> P["runtime-only chmod"]
    P --> G["generator probe"]
    V --> O["record exact output"]
    T --> O
    R --> O
    G --> O

    style S fill:#1f6feb,stroke:#58a6ff,color:#fff
    style A fill:#9e6a03,stroke:#d29922,color:#fff
    style O fill:#238636,stroke:#3fb950,color:#fff
```

## Reproduction command

Run this from the repository root:

```sh
python3 devtools/measure.py
```

The command actually run for this pass printed:

```text
head    e4cd682
tracked_files    48
tracked_executable_files    0
version_rc    0
version_output    toolbox 0.1.0
help_rc    0
help_commands    0
direct_version_rc    126
direct_version_output    PermissionError: [Errno 13] Permission denied: './bin/toolbox'
tests_rc    127
tests_ok    1
tests_not_ok    5
config_ignore_rc    0
config_ignore_output    templates/project/.gitignore:9:config.sh	templates/project/lib/config.sh
scratch_help_rc    0
scratch_help_commands    0
scratch_hello_rc    0
scratch_hello_output    toolbox: Hello, docs-pass!
scratch_generate_rc    1
scratch_generate_output    toolbox: Copying skeleton into <scratch>/depot\n<scratch>/depot/tools/new: line 17: <scratch>/depot/lib/config.sh: No such file or directory
```

The values in the README table are copied from this output. The scratch
`hello` probe sets `USER=docs-pass` so its output does not depend on the
machine's login name. The scratch generator uses the current `HEAD` archive,
adds executable bits only in that temporary tree, and still stops at the
missing generated config library.

## Additional bug probes

The following commands were run separately to isolate defects that the main
probe reports but does not fully explain.

On a temporary copy with runtime executable bits, the macOS shell produced an
empty command listing because `find` does not support `-printf`:

```text
Commands:

  Help:
status=0
```

On the same host, `tools/new --group demo` failed during parsing:

```text
/tmp/toolbox-new.XXXXXX/tools/new: line 119: syntax error near unexpected token `;;'
status=2
```

In the Debian `python:3.12-slim-bookworm` container, `dash` reached the
non-POSIX substitution in `__all_commands`:

```text
bin/toolbox: 112: Bad substitution
status=0
```

The exact temporary-directory suffixes are intentionally not part of the
published result; the command, shell, status and error are what matter.

## What was not measured

The generator could not reach a complete generated toolset from the current
source because `templates/project/lib/config.sh` is absent. Therefore this
pass does not publish command counts, test results or a runtime for a
successful generated project. No animation is claimed: there is no complete
real session to capture from the current checkout. The diagrams in the other
write-ups are source-level explanations, not recordings.

The proposed fixes and the distinction between verified and inferred behavior
are in [`BUGS-FOUND.md`](BUGS-FOUND.md).
