# Repository Guidelines

## Mission & Scope
Toolbox.sh exists to make it trivial to ship portable, metadata-rich command-line tools. We maintain both the framework itself and the authoring experience for downstream projects generated via `tools/generate`.

- Keep the dispatcher, libraries, and templates lean, POSIX-compliant, and well-documented.
- Preserve a frictionless generator workflow backed by tests and real-world examples.
- Ensure the docs in `docs/` stay publish-ready so new projects inherit best practices.

## Docs & Knowledge Base
- **External guide:** update `docs/GENERATOR_GUIDE.md` and the paired gist whenever the workflow shifts.
- **Template docs:** `templates/project/*.md` must contain actionable placeholders for downstream maintainers.
- **Release notes:** summarize notable changes (new commands, breaking behaviour) in PR descriptions; add changelog entries when we cut versions.

## Autogeneration Workflow
- Manifest schema: JSON array of strings (leaf commands) and objects (`{ "name": "deploy", "commands": [...] }`).
- Generator path: `bin/toolbox generate --name NAME --manifest FILE [--dest DIR] [--force]`.
- Command discovery: directories translate to namespaces with `__main` entry points; completions rely on `cmd_emit_metadata`.
- Keep `tools/new`, templates, and docs in sync so generated projects require minimal manual fixes.

## Coding Style & Implementation Notes
- Target `/bin/sh`, `set -eu`, quote inputs, prefer two-space indentation inside blocks.
- When sourcing libraries, use the `_this/_root` resolution pattern for relocation safety.
- Update `CMD_*` metadata whenever command options/behaviour change; completions and help output depend on it.
- Avoid dependencies beyond POSIX tools and `python3` (already required for generation).

## Testing & Verification
- `sh tests/run` must pass before merging (covers dispatcher, metadata, generator).
- Add focused `.t` files under `tests/` for new commands or options; assert exit codes and outputs.
- Generator changes need fixture manifests that exercise nested groups and error paths.
- When modifying templates, run a smoke test by generating a project and executing its suite.

## Pull Requests & Commits
- Commits: single-line, present tense, ≤60 chars (e.g., `wire generator docs link`).
- PRs: include rationale, test commands, relevant manifest snippets, and doc updates if behaviour shifts.
- Link issues/epics when applicable; note UX-facing updates in the PR summary.
- Do not reformat unrelated files—keep diffs scoped.

## Release Checklist
1. Ensure README + docs match the new behaviour.
2. Update `VERSION` and any changelog (if maintained externally).
3. Regenerate completions (`make completions`) and commit if output changed.
4. Cut a tag, share the gist, and announce notable improvements.
