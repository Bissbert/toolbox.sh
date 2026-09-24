#!/usr/bin/env python3
"""Measure the toolbox.sh checkout without changing it.

The scratch probe uses a git archive and changes only permissions inside that
temporary copy. This isolates source behaviour from the checkout's tracked
file modes while keeping the source revision identical.
"""

import io
import os
import re
import subprocess
import tarfile
import tempfile
from pathlib import Path


REPO = Path(__file__).resolve().parent.parent


def run(args, cwd=REPO, env=None):
    merged = os.environ.copy()
    if env:
        merged.update(env)
    try:
        result = subprocess.run(
            args, cwd=cwd, env=merged, capture_output=True, text=True
        )
        return result.returncode, (result.stdout + result.stderr).rstrip()
    except OSError as exc:
        return 126, f"{type(exc).__name__}: {exc}"


def emit(key, value):
    value = str(value).replace("\n", "\\n")
    print(f"{key}\t{value}")


def command_lines(help_text):
    try:
        body = help_text.split("Commands:\n", 1)[1].split("\n\n  Help:", 1)[0]
    except IndexError:
        return []
    return [line.strip() for line in body.splitlines() if line.strip()]


def source_base():
    result = subprocess.run(
        ["git", "merge-base", "HEAD", "main"],
        cwd=REPO,
        capture_output=True,
        text=True,
    )
    if result.returncode == 0:
        return result.stdout.strip()
    return subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=REPO,
        capture_output=True, text=True, check=True,
    ).stdout.strip()


def scratch_probe(revision):
    archive = subprocess.run(
        ["git", "-C", str(REPO), "archive", "--format=tar", revision],
        check=True,
        capture_output=True,
    ).stdout
    with tempfile.TemporaryDirectory(prefix="toolbox-measure-") as name:
        root = Path(name)
        with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
            tar.extractall(root)
        source = root
        for relative in ("bin", "tools", "tests", "templates/project/bin",
                         "templates/project/tools", "templates/project/tests"):
            for path in (source / relative).rglob("*"):
                if path.is_file():
                    path.chmod(path.stat().st_mode | 0o100)

        code, text = run(["/bin/sh", "bin/toolbox", "help"], source)
        emit("scratch_help_rc", code)
        emit("scratch_help_commands", len(command_lines(text)))

        code, text = run(
            ["/bin/sh", "bin/toolbox", "hello", "Alice"],
            source,
            {"USER": "docs-pass"},
        )
        emit("scratch_hello_rc", code)
        emit("scratch_hello_output", text)

        manifest = source / "manifest.json"
        manifest.write_text('["status"]\n')
        code, text = run(
            [
                "/bin/sh", "bin/toolbox", "generate", "--name", "depot",
                "--manifest", "manifest.json", "--dest", "depot", "--force",
            ],
            source,
        )
        emit("scratch_generate_rc", code)
        normalized = text.replace(str(source.resolve()), "<scratch>")
        normalized = normalized.replace("/private" + str(source.resolve()),
                                        "<scratch>")
        normalized = normalized.replace(str(source), "<scratch>")
        emit("scratch_generate_output", normalized)


def main():
    revision = source_base()
    tree_lines = subprocess.run(
        ["git", "ls-tree", "-r", revision], cwd=REPO,
        capture_output=True, text=True, check=True,
    ).stdout.splitlines()
    modes = [line.split()[0] for line in tree_lines]
    emit("source_base", subprocess.run(
        ["git", "rev-parse", "--short", revision], cwd=REPO,
        capture_output=True, text=True, check=True,
    ).stdout.strip())
    emit("tracked_files", len(tree_lines))
    emit("tracked_executable_files", sum(mode == "100755" for mode in modes))

    code, text = run(["/bin/sh", "bin/toolbox", "--version"])
    emit("version_rc", code)
    emit("version_output", text)

    code, text = run(["/bin/sh", "bin/toolbox", "help"])
    emit("help_rc", code)
    emit("help_commands", len(command_lines(text)))

    code, text = run(["./bin/toolbox", "--version"])
    emit("direct_version_rc", code)
    emit("direct_version_output", text)

    code, text = run(["/bin/sh", "tests/run"])
    emit("tests_rc", code)
    emit("tests_ok", len(re.findall(r"^ok ", text, re.MULTILINE)))
    emit("tests_not_ok", len(re.findall(r"^not ok ", text, re.MULTILINE)))

    code, text = run(
        ["git", "check-ignore", "-v", "--no-index",
         "templates/project/lib/config.sh"]
    )
    emit("config_ignore_rc", code)
    emit("config_ignore_output", text)

    scratch_probe(revision)


if __name__ == "__main__":
    main()
