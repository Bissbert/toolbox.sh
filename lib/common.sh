#!/bin/sh
set -eu

PROG=${TOOLBOX_NAME:-toolbox}
is_tty() { [ -t 1 ]; }

die() { printf '%s\n' "$*" >&2; exit 1; }

req_arg() { [ "$#" -ge 2 ] || die "missing argument for $1"; }

command_exists() { command -v -- "$1" >/dev/null 2>&1; }

resolve_command() {
  # Prefer internal tools
  local name path
  name=$1
  path="$TOOLS_DIR/$name"
  if [ -f "$path" ] && [ -x "$path" ]; then
    printf '%s\n' "$path"; return 0
  fi
  # Also allow plugin commands named PROG-name in PATH
  if command_exists "${PROG}-${name}"; then
    command -v -- "${PROG}-${name}"; return 0
  fi
  return 1
}

run() {
  # Echo then run a command safely
  printf '+ %s\n' "$*" >&2
  "$@"
}

