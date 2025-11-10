#!/usr/bin/env bash
set -euo pipefail

# last_d_sections_grep.sh
# Keep only the last N sections that start with DYYYY-MM-DD, then search with ripgrep.
# Works on Ubuntu/macOS (pure awk).

N=7
FILE=""
RG_ARGS=()

usage() {
  cat <<'EOF'
Usage:
  last_d_sections_grep.sh [-n N] [FILE] [-- RG_ARGS...]

Options:
  -n N        Number of trailing D-date sections to keep (default: 7)
  FILE        Input file (if omitted, reads from STDIN)
  --          Everything after -- is passed to ripgrep

Ripgrep:
  By default searches for:
    - unchecked checkboxes:    - [ ]
    - date headers:            ^DYYYY-MM-DD
    - times:                   THH:MM

Examples:
  last_d_sections_grep.sh -n 7 notes.md
  cat notes.md | last_d_sections_grep.sh
  last_d_sections_grep.sh notes.md -- -n --no-heading -C1
EOF
}

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    -n) N="${2:-}"; shift 2 ;;
    --) shift; RG_ARGS=("$@"); break ;;
    -h|--help) usage; exit 0 ;;
    *) if [[ -z "$FILE" ]]; then FILE="$1"; shift; else echo "Unexpected arg: $1" >&2; usage; exit 1; fi ;;
  esac
done

# Prepare awk program to keep last N D-date sections
AWK_PROG='
  /^D[0-9]{4}-[0-9]{2}-[0-9]{2}/ { idx[++c]=NR }
  { buf[NR]=$0 }
  END {
    start = (c>=N ? idx[c-N+1] : 1)
    for (i=start; i<=NR; i++) print buf[i]
  }
'

# Slice input to last N sections
if [[ -n "$FILE" ]]; then
  SLICE="$(awk -v N="$N" "$AWK_PROG" "$FILE")"
else
  SLICE="$(awk -v N="$N" "$AWK_PROG")"
fi

# Run ripgrep on the slice
# Defaults: show line numbers and no file headings; user can override via RG_ARGS
rg ${RG_ARGS[@]:-} -n --no-heading \
  -e '- \[ \]' \
  -e '^D[0-9]{4}-[0-9]{2}-[0-9]{2}' \
  -e 'T[0-9]{2}:[0-9]{2}' \
  <<< "$SLICE"

