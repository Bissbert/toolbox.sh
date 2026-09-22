#!/bin/sh
set -eu

# Determine XDG paths with fallbacks
_xdg_home() {
  var=$1; def=$2
  eval v="\${$var-}"
  [ -n "${v:-}" ] && { printf '%s\n' "$v"; return; }
  printf '%s\n' "$def"
}

XDG_CONFIG_HOME=$(_xdg_home XDG_CONFIG_HOME "$HOME/.config")
XDG_DATA_HOME=$(_xdg_home XDG_DATA_HOME "$HOME/.local/share")
XDG_CACHE_HOME=$(_xdg_home XDG_CACHE_HOME "$HOME/.cache")

TOOLBOX_CONFIG_DIR=${TOOLBOX_CONFIG_DIR:-"$XDG_CONFIG_HOME/$TOOLBOX_NAME"}
TOOLBOX_DATA_DIR=${TOOLBOX_DATA_DIR:-"$XDG_DATA_HOME/$TOOLBOX_NAME"}
TOOLBOX_CACHE_DIR=${TOOLBOX_CACHE_DIR:-"$XDG_CACHE_HOME/$TOOLBOX_NAME"}

mkdir_p() { [ -d "$1" ] || mkdir -p "$1"; }

load_config() {
  # Optional custom file overrides default
  local file=${1:-}
  if [ -n "$file" ]; then
    [ -f "$file" ] && . "$file" || { printf 'config not found: %s\n' "$file" >&2; exit 2; }
    return 0
  fi
  local def="$TOOLBOX_CONFIG_DIR/config"
  if [ -f "$def" ]; then . "$def"; fi
}

ensure_dirs() {
  # Create XDG dirs if possible; ignore failures in restricted envs
  for d in "$TOOLBOX_CONFIG_DIR" "$TOOLBOX_DATA_DIR" "$TOOLBOX_CACHE_DIR"; do
    [ -d "$d" ] || { mkdir -p "$d" 2>/dev/null || :; }
  done
}

export TOOLBOX_CONFIG_DIR TOOLBOX_DATA_DIR TOOLBOX_CACHE_DIR
