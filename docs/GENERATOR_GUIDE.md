# Toolbox.sh Project Generator Guide

Toolbox.sh ships with a JSON-driven generator that scaffolds portable POSIX shell CLIs in seconds. Use this guide as the README for newly generated repositories—it explains the workflow, directory layout, and tasks maintainers should tackle next.

## Why Toolbox.sh
- **Portable:** every script targets `/bin/sh`, no bashisms required.
- **Structured:** Git-style command/namespace layout with `__main` entry points for groups.
- **Metadata aware:** auto-generated help output and tab-completion powered by `lib/cmd.sh`.
- **Tested:** TAP-style harness and generator tests keep regressions out.

## Requirements
- POSIX shell + coreutils (already present on Linux/macOS).
- `python3` for manifest parsing and templating.
- Optional: `git` if you plan to use `self-update --from-git`.

## Quick Start
1. **Describe your command tree**
   ```json
   [
     "status",
     { "name": "release", "commands": [
       "plan",
       { "name": "deploy", "commands": ["canary", "prod"] }
     ] }
   ]
   ```
2. **Generate a project**
   ```sh
   bin/toolbox generate --name demo --manifest manifest.json --dest ./demo
   ```
3. **Review the output**
   - `bin/demo` — dispatcher renamed to match `--name`.
   - `tools/` — command tree; directories denote groups, `__main` provides group help.
   - `lib/` — shared helpers (`common.sh`, `log.sh`, `args.sh`, `config.sh`, `cmd.sh`).
   - `templates/command/` — stubs consumed by `tools/new` when you add more commands.
   - `docs/` — includes this guide and a gist template.
4. **Implement command logic** using the metadata placeholders in each generated script.
5. **Run tests** before sharing:
   ```sh
   sh tests/run
   ```

## Manifest Rules
- Root manifest must be a JSON array.
- Leaf commands are strings (`"status"`).
- Command groups are objects with a `name` and `commands` array.
- Groups can be nested arbitrarily; directories are created automatically.
- Names should be lowercase/hyphenated to align with file paths.
- Validation errors halt generation with a descriptive message—fix the offending node and rerun.

## Command Metadata
Each generated script sources `lib/cmd.sh`. Update these fields as you implement behaviour:
- `CMD_USAGE`, `CMD_SUMMARY`, `CMD_DESCRIPTION` — displayed in `--help` output.
- `CMD_OPTIONS` — list flags as `--flag|VALUE|Description`; one entry per line.
- `CMD_SUBCOMMANDS` — populate in group `__main` files to advertise child commands.
- `CMD_EXAMPLES` — add realistic invocations for docs and demos.
Keeping metadata accurate ensures `bin/<name> completion` produces correct Bash/Zsh scripts.

## Working With Templates
- Customize `templates/command/leaf` and `templates/command/group` to bake in organisation-wide defaults (logging, global flags, analytics).
- Run `bin/<name> new analytics cohort` (or similar) to scaffold additional commands using your updated templates.
- Update `templates/project/README.md` and `templates/project/AGENTS.md` so future repos start with accurate documentation.

## Testing & CI Recommendations
- The TAP harness (`tests/run`) writes isolated artefacts under `.tmp-tests/`.
- Create one `.t` file per command; assert exit status and relevant stdout/stderr.
- Exercise the generator in CI by running `bin/toolbox generate` with a sample manifest and executing the new project’s tests.
- Keep fixtures small—prefer focused manifests to reduce CI time.

## Maintenance Checklist
- Regenerate completions after adding flags: `bin/<name> completion bash > completions/<name>.bash`.
- Run `make test` before tagging releases or publishing generated templates.
- Update documentation placeholders in `docs/` and the root `README.md` as you add features.
- Use `tools/self-update --from-path` to sync local installations with the latest framework.

## Troubleshooting
- **Missing python3:** install via `apt install python3`, `brew install python`, or equivalent.
- **Unknown command after generation:** ensure the command script is executable (`chmod +x`).
- **Help output missing options:** populate `CMD_OPTIONS` and rerun `--help` to verify.
- **Completion script stale:** rerun `bin/<name> completion bash|zsh` after changing metadata.

## Shipping & Packaging Ideas
- Tag releases and publish signed tarballs (use `make dist`) so consumers can run `make install-user` without cloning.
- Build Debian packages with `make deb` and push them to your apt repository for managed installs.
- Provide a Homebrew tap or Linuxbrew formula that stages the tarball and links the dispatcher.
- Offer a `curl | sh` installer that downloads the latest release and installs to `~/.local/opt`.
- Build an OCI image (`ghcr.io/<org>/toolbox-generator`) for CI pipelines that only need `toolbox generate`.
- Consider OS-native packages (Deb/RPM/Nix) if your team’s deployment targets rely on them.

## Next Steps for New Projects
1. Replace placeholders in `README.md`, `AGENTS.md`, and `TODO.md` with project-specific content.
2. Review command stubs and implement real behaviour.
3. Connect the project to CI with `sh tests/run` as the primary job.
4. Share the quickstart gist (see `docs/GENERATOR_GIST.md`) with your team.
