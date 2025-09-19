#!/bin/sh
# Command metadata helpers shared by generated subcommands.
set -eu

cmd__ensure_defaults() {
  CMD_NAME=${CMD_NAME:-${TOOLBOX_CMD_PATH:-}}
  CMD_SUMMARY=${CMD_SUMMARY:-}
  if [ -z "${CMD_USAGE:-}" ]; then
    if [ -n "$CMD_NAME" ]; then
      CMD_USAGE="${TOOLBOX_NAME} ${CMD_NAME}"
    else
      CMD_USAGE="${TOOLBOX_NAME} <command>"
    fi
  fi
  CMD_OPTIONS=${CMD_OPTIONS:-}
  CMD_DESCRIPTION=${CMD_DESCRIPTION:-}
  CMD_EXAMPLES=${CMD_EXAMPLES:-}
  CMD_SUBCOMMANDS=${CMD_SUBCOMMANDS:-}
}

cmd__standard_options() {
  cat <<'__CMD_STD__'
-h,--help||Show help information
__CMD_STD__
}

cmd__option_lines() {
  cmd__standard_options
  if [ -n "$CMD_OPTIONS" ]; then
    printf '%s\n' "$CMD_OPTIONS"
  fi
}

cmd__format_flags() {
  printf '%s' "$1" | sed 's/,/, /g'
}

cmd__print_options_section() {
  local flags value desc display
  cmd__option_lines | while IFS='|' read -r flags value desc; do
    case "$flags" in
      ''|'#'*) continue ;;
    esac
    display=$(cmd__format_flags "$flags")
    if [ -n "$value" ]; then
      display="$display $value"
    fi
    if [ -n "$desc" ]; then
      printf '  %s\n      %s\n' "$display" "$desc"
    else
      printf '  %s\n' "$display"
    fi
  done
}

cmd__print_subcommands() {
  [ -n "$CMD_SUBCOMMANDS" ] || return 0
  printf '\nSubcommands:\n'
  printf '%s\n' "$CMD_SUBCOMMANDS" | while IFS= read -r sub; do
    [ -n "$sub" ] || continue
    printf '  %s\n' "$sub"
  done
}

cmd__print_examples() {
  [ -n "$CMD_EXAMPLES" ] || return 0
  printf '\nExamples:\n'
  printf '%s\n' "$CMD_EXAMPLES" | while IFS= read -r ex; do
    [ -n "$ex" ] || continue
    printf '  %s\n' "$ex"
  done
}

cmd_render_help() {
  cmd__ensure_defaults
  if [ -n "$CMD_USAGE" ]; then
    printf 'Usage: %s\n' "$CMD_USAGE"
  fi
  if [ -n "$CMD_SUMMARY" ]; then
    printf '\n%s\n' "$CMD_SUMMARY"
  fi
  if [ -n "$CMD_DESCRIPTION" ]; then
    printf '\n%s\n' "$CMD_DESCRIPTION"
  fi
  printf '\nOptions:\n'
  cmd__print_options_section
  cmd__print_subcommands
  cmd__print_examples
}

cmd_show_help() {
  cmd_render_help
  exit 0
}

cmd_maybe_handle_flag() {
  case "$1" in
    -h|--help)
      cmd_show_help
      ;;
    --toolbox-meta)
      cmd_emit_metadata
      exit 0
      ;;
  esac
  return 1
}

cmd_emit_metadata() {
  cmd__ensure_defaults
  printf 'name|%s\n' "$CMD_NAME"
  if [ -n "$CMD_SUMMARY" ]; then
    printf 'summary|%s\n' "$CMD_SUMMARY"
  fi
  printf 'usage|%s\n' "$CMD_USAGE"
  if [ -n "$CMD_DESCRIPTION" ]; then
    printf 'description|%s\n' "$CMD_DESCRIPTION"
  fi
  if [ -n "$CMD_SUBCOMMANDS" ]; then
    printf '%s\n' "$CMD_SUBCOMMANDS" | while IFS= read -r sub; do
      [ -n "$sub" ] || continue
      printf 'subcommand|%s\n' "$sub"
    done
  fi
  cmd__option_lines | while IFS='|' read -r flags value desc; do
    case "$flags" in
      ''|'#'*) continue ;;
    esac
    printf 'option|%s|%s|%s\n' "$flags" "$value" "$desc"
  done
  if [ -n "$CMD_EXAMPLES" ]; then
    printf '%s\n' "$CMD_EXAMPLES" | while IFS= read -r ex; do
      [ -n "$ex" ] || continue
      printf 'example|%s\n' "$ex"
    done
  fi
}
