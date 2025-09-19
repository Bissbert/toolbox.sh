# TODO

- [x] Extend `tools/generate`/`tools/new` to accept JSON manifests (`[{"name","commands"}, "leaf"]`) and scaffold nested command trees.
- [x] Introduce metadata-bearing templates (`templates/command/leaf|group`) wired into `lib/cmd.sh` helpers for help/completion parity.
- [x] Update `bin/toolbox` discovery to handle recursive command directories and expose `__commands`/`__command_meta` for completions.
- [x] Teach `tools/completion` to consume metadata and support nested command paths for Bash/Zsh.
- [x] Add TAP coverage for generator workflows, metadata, and nested dispatch (`tests/generate.t`, updated `cli.t`).
- [x] Document generator usage in `docs/` once we publish an external tutorial.
