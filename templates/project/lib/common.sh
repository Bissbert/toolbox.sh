#!/bin/sh
set -eu

PROG=${TOOLBOX_NAME:-toolbox}

is_tty() { [ -t 1 ]; }

command_exists() { command -v -- "$1" >/dev/null 2>&1; }

die() { printf '%s\n' "$*" >&2; exit 1; }

resolve_command() {
  # Resolve a (possibly nested) command path to an executable script.
  # Usage: resolve_command cmd [subcmd ...]
  # Prints: path|consumed_count|command_path
  [ "$#" -ge 1 ] || return 1

  local path="$TOOLS_DIR" script="" consumed=0 segments="" first="$1"
  local segment

  while [ "$#" -gt 0 ]; do
    segment=$1
    if [ -f "$path/$segment" ] && [ -x "$path/$segment" ]; then
      script="$path/$segment"
      consumed=$((consumed + 1))
      if [ -n "$segments" ]; then
        segments="$segments $segment"
      else
        segments=$segment
      fi
      shift
      break
    fi
    if [ -d "$path/$segment" ]; then
      path="$path/$segment"
      consumed=$((consumed + 1))
      if [ -n "$segments" ]; then
        segments="$segments $segment"
      else
        segments=$segment
      fi
      shift
      continue
    fi
    break
  done

  if [ -n "$script" ]; then
    printf '%s|%s|%s\n' "$script" "$consumed" "$segments"
    return 0
  fi

  if [ "$#" -eq 0 ] && [ -x "$path/__main" ] && [ "$consumed" -gt 0 ]; then
    printf '%s|%s|%s\n' "$path/__main" "$consumed" "$segments"
    return 0
  fi

  if [ "$consumed" -eq 1 ] && command_exists "${PROG}-${first}"; then
    printf '%s|%s|%s\n' "$(command -v -- "${PROG}-${first}")" "$consumed" "$first"
    return 0
  fi

  return 1
}

run() {
  # Echo then run a command safely
  printf '+ %s\n' "$*" >&2
  "$@"
}
