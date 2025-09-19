# Contributor Playbook

> Replace this section with a short paragraph describing the domain, audience, and expectations for contributors.

## Project Goals
- Summarise the problems this CLI solves and the metrics that define success.
- Highlight any guiding principles (security-first, UX-first, zero-downtime, etc.).

## Command Tree & Ownership
- Document the primary commands/subcommands and who owns each (squads, individuals).
- Reference the manifest or internal design docs if they live elsewhere.

## Coding Standards
- Shell style: confirm indentation (e.g., two spaces), quoting rules, and acceptable external tools.
- Metadata: remind contributors to keep `CMD_USAGE`, `CMD_OPTIONS`, `CMD_EXAMPLES`, and `CMD_SUBCOMMANDS` current.
- Logging: specify the required log level defaults and helper functions (`inf`, `err`, `dbg`).

## Testing Expectations
- List required test commands (`sh tests/run`, additional integration suites).
- Describe how to add new `.t` files and any naming conventions.
- Capture coverage or quality gates if enforced (e.g., "new commands need at least one happy-path + one failure test").

## Documentation Workflow
- Outline where public docs live (`README`, `docs/`, wikis) and how to update them when behaviour changes.
- Mention any templates (release notes, user guides) that must be filled in for significant updates.

## Pull Requests & Reviews
- Provide commit message conventions and PR checklist expectations (screenshots, CLI transcripts, linked tickets).
- Define the review process (required approvers, timelines, labels).
- State merging rules (fast-forward only, squash, rebase).

## Operations & Releases
- Detail how releases are cut (tagging, packaging, distribution channels).
- Note monitoring/alerting steps if the CLI affects production systems.
- Include escalation contacts or runbooks for incident response.

> Delete placeholder bullets as you populate the sections, and add any locally relevant policies (security reviews, data-handling requirements, etc.).
