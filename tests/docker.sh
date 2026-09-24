#!/bin/sh
# Run the test suite in a Debian container (dash as /bin/sh) with the working
# tree as it is now, including uncommitted changes.
#
#   sh tests/docker.sh
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
docker run --rm -v "$REPO":/repo:ro python:3.12-slim-bookworm sh -c '
apt-get -qq update >/dev/null 2>&1 && apt-get -qq install -y git make >/dev/null 2>&1
git config --global --add safe.directory "*"
cp -a /repo /tmp/tb && cd /tmp/tb && rm -rf .tmp-tests
sh tests/run > /tmp/t.log 2>&1; rc=$?
cat /tmp/t.log
printf "\nSummary: %s passed, %s failed (exit %s)\n" "$(grep -c "^ok " /tmp/t.log)" "$(grep -c "^not ok " /tmp/t.log)" "$rc"
exit $rc
'
