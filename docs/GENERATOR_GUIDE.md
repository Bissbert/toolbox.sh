[← back to the overview](../README.md)

# Project generator guide

`tools/generate` turns a JSON manifest into a command-tree skeleton. A string
is a leaf command. An object has a `name` and a `commands` array, and becomes a
group directory with an executable `__main` file. Nested objects are walked
recursively.

```mermaid
flowchart TD
    A["write manifest.json"] --> B{"valid JSON list?"}
    B -->|"no"| E["report validation error"]
    B -->|"yes"| C["copy templates/project"]
    C --> D["remove sample command and test"]
    D --> F["rename bin/toolbox"]
    F --> G["copy command templates"]
    G --> H["create leaf and group paths"]
    H --> I["run generated dispatcher"]

    style A fill:#9e6a03,stroke:#d29922,color:#fff
    style H fill:#1f6feb,stroke:#58a6ff,color:#fff
    style I fill:#238636,stroke:#3fb950,color:#fff
    style E fill:#da3633,stroke:#f85149,color:#fff
```

## Manifest shape

```json
[
  "status",
  {
    "name": "report",
    "commands": ["daily", {"name": "archive", "commands": ["list"]}]
  }
]
```

The resulting paths are conceptually:

```text
tools/status
tools/report/__main
tools/report/daily
tools/report/archive/__main
tools/report/archive/list
```

The generator also copies the project README, Makefile, libraries, test
harness, command templates and built-in project tools. The generated
dispatcher is renamed to the manifest's `--name` value.

## Adding a command after generation

The intended lifecycle for a new command is:

```mermaid
flowchart LR
    A["choose path"] --> B["bin/<name> new path"]
    B --> C["copy leaf or group template"]
    C --> D["replace command placeholders"]
    D --> E["edit implementation"]
    E --> F["fill CMD_* metadata"]
    F --> G["run help and tests"]

    style B fill:#1f6feb,stroke:#58a6ff,color:#fff
    style E fill:#9e6a03,stroke:#d29922,color:#fff
    style G fill:#238636,stroke:#3fb950,color:#fff
```

For a leaf, the last path segment is the file name. For a group, `--group`
creates the directory and its `__main` file. The templates expect the command
to source the libraries relative to the project root and to keep metadata
close to the implementation.

## Current checkout behavior

The source-level sequence is copy-pasteable:

```sh
cat >manifest.json <<'JSON'
["status", {"name": "report", "commands": ["daily"]}]
JSON
/bin/sh bin/toolbox generate --name depot --manifest manifest.json --dest ./depot
```

It is not a successful quick start on the current revision. Direct invocation
was blocked by tracked file modes; after permissions were prepared inside a
scratch archive, the generator copied its skeleton and then `tools/new` could
not source `depot/lib/config.sh`. That failure was observed by
`devtools/measure.py`, and no successful generated-project transcript was
claimed at the time.

The missing library, the ignore rule and the related dispatcher defects have
since been fixed on the default branch, where the same probe runs to
completion. Their reproductions and diffs are collected in
[`BUGS-FOUND.md`](BUGS-FOUND.md).
