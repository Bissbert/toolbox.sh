#!/bin/sh
# Runs every check in docs/measurement.md inside a Linux container.
#
#   sh devtools/linux-run.sh > media/captures/linux-run.txt
#
# The repository (with its .git) is mounted read-only and copied inside the
# container. /bin/sh there is dash; the test suite is also run under bash.
set -eu

REPO=$(cd "$(dirname "$0")/.." && pwd)
IMAGE=python:3.12-slim-bookworm

docker pull -q "$IMAGE" >/dev/null
docker run --rm -v "$REPO":/repo:ro "$IMAGE" sh -c '
section() { printf "\n=== %s\n" "$*"; }
apt-get -qq update >/dev/null 2>&1 && apt-get -qq install -y git >/dev/null 2>&1
git config --global --add safe.directory "*"
cp -a /repo /tmp/tb && cd /tmp/tb
S=/tmp/scratch && mkdir -p $S

section "environment"
uname -srm
printf "/bin/sh -> %s\n" "$(readlink -f /bin/sh)"
bash --version | head -1
git --version
python3 --version
printf "commit %s\n" "$(git rev-parse --short HEAD)"

section "python3 devtools/measure.py"
python3 devtools/measure.py | sed "s#/tmp/[^ ]*toolbox-measure-[^/ ]*#<scratch>#g"

section "1. tracked modes and direct execution"
git ls-files -s | awk "{print \$1}" | sort | uniq -c
./bin/toolbox --version; echo "exit=$?"

section "3. ignore rule for templates/project/lib/config.sh"
git check-ignore -v --no-index templates/project/lib/config.sh; echo "exit=$? (1 = not ignored)"

section "4. command discovery (help)"
./bin/toolbox help; echo "exit=$?"

section "5. positional arguments reach the leaf"
USER=nobody ./bin/toolbox hello Alice; echo "exit=$?"

section "8. __all_commands under dash"
sh bin/toolbox __all_commands; echo "exit=$?"

section "2, 6, 9, 10. generate a project with a nested command"
cd $S
printf "%s\n" "[\"status\", {\"name\": \"report\", \"commands\": [\"daily\"]}]" > manifest.json
/tmp/tb/bin/toolbox generate --name depot --manifest manifest.json --dest ./depot 2>&1 | sed "s#$S#<scratch>#g"; echo "exit=$?"
cd depot
ls lib
echo "--- bin/depot help"
./bin/depot help; echo "exit=$?"
echo "--- bin/depot report daily --help"
./bin/depot report daily --help; echo "exit=$?"
echo "--- bin/depot report daily"
./bin/depot report daily 2>&1 | sed "s#$S#<scratch>#g"; echo "exit=$?"

section "7. tools/new --group"
./bin/depot new --group demo 2>&1 | sed "s#$S#<scratch>#g"; echo "exit=$?"
./bin/depot help | sed -n "/Commands:/,/^\$/p"

section "tests/run under dash"
cd /tmp/tb
sh tests/run > /tmp/dash.log 2>&1; rc=$?
printf "exit=%s ok=%s not_ok=%s\n" $rc "$(grep -c "^ok " /tmp/dash.log)" "$(grep -c "^not ok " /tmp/dash.log)"

section "tests/run under bash"
bash tests/run > /tmp/bash.log 2>&1; rc=$?
printf "exit=%s ok=%s not_ok=%s\n" $rc "$(grep -c "^ok " /tmp/bash.log)" "$(grep -c "^not ok " /tmp/bash.log)"

section "generated project: tests/run"
cd $S/depot && sh tests/run > /tmp/gen.log 2>&1; rc=$?
printf "exit=%s ok=%s not_ok=%s\n" $rc "$(grep -c "^ok " /tmp/gen.log)" "$(grep -c "^not ok " /tmp/gen.log)"
grep "^not ok" /tmp/gen.log || true
'
