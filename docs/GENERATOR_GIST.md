[← back to the overview](../README.md)

# Generator gist

```mermaid
flowchart LR
    M["manifest"] --> G["generate"]
    G --> P["project tree"]
    P --> C["edit command and CMD_* metadata"]
    C --> T["run help and tests"]

    style M fill:#9e6a03,stroke:#d29922,color:#fff
    style G fill:#1f6feb,stroke:#58a6ff,color:#fff
    style T fill:#238636,stroke:#3fb950,color:#fff
```

The generator accepts a list of leaf names and command-group objects:

```sh
cat >manifest.json <<'JSON'
[
  "status",
  {"name": "report", "commands": ["daily", "weekly"]}
]
JSON
/bin/sh bin/toolbox generate --name depot --manifest manifest.json --dest ./depot
```

The source contract is:

| Manifest value | Generated path |
|---|---|
| `"status"` | `tools/status` |
| group object | `tools/<group>/__main` |
| child of a group | `tools/<group>/<child>` |

After generation, edit the command file and replace its `CMD_*` placeholders.
Use `--help` to inspect the metadata that the command exposes, then add a TAP
test under `tests/`.

The checkout this documentation pass described could not complete the sequence:
the executable-bit, missing-library and dispatcher defects are measured in
[`measurement.md`](measurement.md) and listed in
[`BUGS-FOUND.md`](BUGS-FOUND.md). All of them have since been fixed on the
default branch, where the sequence runs end to end.
