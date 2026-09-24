[← back to the overview](../README.md)

# Bugs found

Entries 1–10 were reproduced on the checkout at `e4cd682` and are fixed on
`main`. Entry 11 turned up when everything was re-run in a Linux container and
is open. The checks quoted below come from that run; see
[How this was measured](measurement.md).

| # | Entry | Status |
|---|---|---|
| 1 | Tracked scripts have no executable bit | Fixed in [`1709acf`](https://github.com/Bissbert/toolbox.sh/commit/1709acf) |
| 2 | The generated project has no `lib/config.sh` | Fixed in [`5d89519`](https://github.com/Bissbert/toolbox.sh/commit/5d89519) |
| 3 | The template ignore rule hides nested `config.sh` | Fixed in [`3e96df1`](https://github.com/Bissbert/toolbox.sh/commit/3e96df1) |
| 4 | GNU `find -printf` breaks discovery on macOS | Fixed in [`6b1fe41`](https://github.com/Bissbert/toolbox.sh/commit/6b1fe41) |
| 5 | The dispatcher drops positional arguments | Fixed in [`c0ba03d`](https://github.com/Bissbert/toolbox.sh/commit/c0ba03d) |
| 6 | Nested generated commands source the wrong root | Fixed in [`ed519f9`](https://github.com/Bissbert/toolbox.sh/commit/ed519f9) |
| 7 | `tools/new` has a macOS parse error in its command substitution | Fixed in [`c58633c`](https://github.com/Bissbert/toolbox.sh/commit/c58633c) |
| 8 | `_list_all_command_paths` uses a non-POSIX substitution | Fixed in [`fc4dabd`](https://github.com/Bissbert/toolbox.sh/commit/fc4dabd) |
| 9 | Generated help keeps variable references literal | Fixed in [`6715cf4`](https://github.com/Bissbert/toolbox.sh/commit/6715cf4) |
| 10 | Generated command examples keep `${TOOLBOX_NAME}` literal | Fixed in [`272de6b`](https://github.com/Bissbert/toolbox.sh/commit/272de6b) |
| 11 | A generated project's own tests target the template | Open |

## 1. Tracked scripts have no executable bit

**Status:** fixed in [`1709acf`](https://github.com/Bissbert/toolbox.sh/commit/1709acf).

**What happened:** 21 entry points (`bin/toolbox`, everything in `tools/` and
`tests/`, the packaging scripts and their copies under `templates/project/`)
were tracked as `100644`. `./bin/toolbox --version` failed with status `126`,
and `/bin/sh bin/toolbox help` listed no commands, because discovery only
accepts executable files.

**What changed:** those files are tracked as `100755`; sourced libraries stay
`100644`.

**Check:** `git ls-files -s` counts 21 files with mode `100755`, and
`./bin/toolbox --version` prints `toolbox 0.1.0` with exit `0`.

## 2. The generated project has no `lib/config.sh`

**Status:** fixed in [`5d89519`](https://github.com/Bissbert/toolbox.sh/commit/5d89519).

**What happened:** `templates/project/lib/config.sh` did not exist, but the
generated `tools/new` sources it. Generation copied the skeleton and then
stopped:

```text
<scratch>/depot/tools/new: line 17: <scratch>/depot/lib/config.sh: No such file or directory
```

**What changed:** `templates/project/lib/config.sh` was added, matching the
top-level `lib/config.sh`.

**Check:** generating `depot` from a manifest with `status` and a `report`
group exits `0`, and `depot/lib/` contains `config.sh`.

## 3. The template ignore rule hides nested `config.sh`

**Status:** fixed in [`3e96df1`](https://github.com/Bissbert/toolbox.sh/commit/3e96df1).

**What happened:** `templates/project/.gitignore` and
`templates/command/gitignore` held unanchored `config` and `config.sh`
patterns, so `git check-ignore` matched the nested `lib/config.sh` as well as a
private config file at the project root.

**What changed:** both patterns are anchored as `/config` and `/config.sh` in
both files.

**Check:** `git check-ignore -v --no-index templates/project/lib/config.sh`
exits `1` (not ignored).

## 4. GNU `find -printf` breaks discovery on macOS

**Status:** fixed in [`6b1fe41`](https://github.com/Bissbert/toolbox.sh/commit/6b1fe41).

**What happened:** both dispatchers and both copies of `tools/new` listed
commands with `find -printf`. BSD `find` on macOS rejects it, the error was
redirected, and `help` printed an empty `Commands:` section.

**What changed:** the listing uses shell globs with executable and directory
tests and a locale-stable sort. Hidden entries and `__main` are still skipped.

**Check:** in the Linux container `help` lists `completion`, `generate`,
`hello`, `new` and `self-update`. GNU `find` accepts `-printf`, so the Linux run
shows the new listing works but does not reproduce the macOS failure.

## 5. The dispatcher drops positional arguments

**Status:** fixed in [`c0ba03d`](https://github.com/Bissbert/toolbox.sh/commit/c0ba03d).

**What happened:** while working out the command path, the dispatcher shifted
every non-option token and then passed none of them to the script.
`toolbox hello Alice` greeted `$USER` instead of `Alice`, and
`toolbox new report weekly` reached `tools/new` without its path.

**What changed:** a token joins the command path only when `resolve_command`
consumes it. The rest are passed to the script.

**Check:** `USER=nobody ./bin/toolbox hello Alice` prints
`toolbox: Hello, Alice!`.

## 6. Nested generated commands source the wrong root

**Status:** fixed in [`ed519f9`](https://github.com/Bissbert/toolbox.sh/commit/ed519f9).

**What happened:** the command templates computed the project root with
`${_dir%/tools}`. For `tools/report/daily` that left the root at
`tools/report`, and the script failed to source
`tools/report/lib/common.sh`.

**What changed:** the leaf and group templates and both copies of `tools/new`
cut the path at the `/tools/` boundary.

**Check:** in the generated project, `./bin/depot report daily --help` prints
its usage and `./bin/depot report daily` runs its stub, both with exit `0`.

## 7. `tools/new` has a macOS parse error in its command substitution

**Status:** fixed in [`c58633c`](https://github.com/Bissbert/toolbox.sh/commit/c58633c).

**What happened:** a `case` branch ending in `continue ;;` sat inside a command
substitution. The macOS `sh` rejected it (`syntax error near unexpected token
';;'`), so `tools/new --group` exited `2`.

**What changed:** the child filter is an `if` inside the substitution.

**Check:** `./bin/depot new --group demo` creates `demo/__main`, and `help`
then lists `demo`. As with entry 4, the Linux run does not reproduce the
macOS-only parse error.

## 8. `_list_all_command_paths` uses a non-POSIX substitution

**Status:** fixed in [`fc4dabd`](https://github.com/Bissbert/toolbox.sh/commit/fc4dabd).

**What happened:** `${rel//\// }` is Bash syntax. Under `dash`,
`sh bin/toolbox __all_commands` printed `bin/toolbox: 112: Bad substitution`
and still exited `0`, so completion got no command list.

**What changed:** both dispatchers convert the path with `tr '/' ' '`.

**Check:** under `dash`, `sh bin/toolbox __all_commands` prints the five
commands and exits `0`.

## 9. Generated help keeps variable references literal

**Status:** fixed in [`6715cf4`](https://github.com/Bissbert/toolbox.sh/commit/6715cf4).

**What happened:** the generated dispatcher's help heredoc was quoted, so help
printed `${TOOLBOX_NAME} ${TOOLBOX_VERSION}` and `$(_usage_commands)`
literally.

**What changed:** the heredoc delimiter is unquoted.

**Check:** `./bin/depot help` starts with `depot 0.1.0` and lists the
generated commands.

## 10. Generated command examples keep `${TOOLBOX_NAME}` literal

**Status:** fixed in [`272de6b`](https://github.com/Bissbert/toolbox.sh/commit/272de6b).

**What happened:** the leaf and group templates used a quoted examples
heredoc, so `Examples:` printed `${TOOLBOX_NAME}` instead of the project
name.

**What changed:** the examples heredoc in both templates is unquoted.

**Check:** `./bin/depot report daily --help` ends with
`Examples:` / `depot report daily`.

## 11. A generated project's own tests target the template

**Status:** open. Found in the Linux run.

**Files:** `templates/project/tests/cli.t`, `templates/project/tests/generate.t`,
`templates/project/tests/harness.sh:13`, `tools/generate:99`

**What happens:** the generator copies `templates/project/tests/` into the new
project, renames `bin/toolbox` to `bin/<name>`, and deletes `tools/hello` and
`tests/hello.t`. The two remaining test files still run `$_ROOT/bin/toolbox`
(the harness default), and expect `hello` and `generate` commands, which a
generated project does not have. `tests/run` in a fresh project therefore fails
every assertion.

**Reproduce:** generate `depot` as in the README, then:

```sh
cd depot && sh tests/run
```

```text
not ok 1 - help shows commands header
  ---
    pattern: Commands:
    got:     sh: 0: cannot open <scratch>/depot/bin/toolbox: No such file
```

The run ends with `exit=1 ok=0 not_ok=14`.

**Possible fix:** have the generator set the harness's default `TOOL` to
`bin/<name>` and drop or rewrite the `hello` and `generate` assertions, or
ship a smaller test file that only checks `help` and the manifest's commands.
