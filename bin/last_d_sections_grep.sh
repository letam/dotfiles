#!/usr/bin/env bash
set -euo pipefail

# last_d_sections_grep.sh — filter to the last N date (DYYYY-MM-DD) sections, then search with ripgrep
# Reference: https://chatgpt.com/share/69114b5c-ab74-8010-b58e-9e1cea6adc77
#
# DESCRIPTION
#   Reads a Markdown/notes file organized into “date sections” whose headers begin
#   with `DYYYY-MM-DD` (e.g., `D2025-11-09`). It first trims the input down to only
#   the last N such sections (from the bottom of the file), preserving their order,
#   and then runs ripgrep (rg) to surface lines matching any of:
#     • unchecked checkboxes:  `- [ ]`
#     • date headers:          `^DYYYY-MM-DD`
#     • times:                 `T[0-9]{2}:[0-9]{2}` (e.g., T14:35)
#
#   This is useful for quickly focusing on your most recent notes without doing any
#   calendar math, and works identically on Ubuntu/Linux and macOS (pure awk).
#
# SYNOPSIS
#   last_d_sections_grep.sh [-n N] [FILE] [-- RG_ARGS...]
#
# OPTIONS
#   -n N           Keep only the last N date sections (default: 7).
#   FILE           Input file to read. If omitted, reads from STDIN.
#   --             Everything after `--` is passed through to `rg` unchanged.
#
# DEFAULT RIPGREP PATTERNS
#   -e '- \[ \]'                             (unchecked Markdown checkbox)
#   -e '^D[0-9]{4}-[0-9]{2}-[0-9]{2}'        (date header lines)
#   -e 'T[0-9]{2}:[0-9]{2}'                  (time tokens like T09:30)
#
# EXAMPLES
#   # Search within the last 7 sections of notes.md (show line numbers, no headings):
#   last_d_sections_grep.sh -n 7 notes.md
#
#   # Read from STDIN and keep last 3 sections:
#   cat notes.md | last_d_sections_grep.sh -n 3
#
#   # Pass extra rg flags after `--` (e.g., add 1 line of context around matches):
#   last_d_sections_grep.sh notes.md -- -C1
#
# BEHAVIOR
#   • Section detection: A “section” starts at any line matching `^DYYYY-MM-DD`.
#     All lines up to (but not including) the next such header belong to that section.
#   • Slicing logic: The script scans once to record header line numbers, computes
#     the starting line of the Nth-from-last section (or beginning of file if fewer),
#     and prints from there to EOF before handing it to `rg`.
#   • If the file contains fewer than N date sections, the entire file is searched.
#
# DEPENDENCIES
#   • awk (POSIX) — used for section slicing, portable across Linux/macOS.
#   • rg (ripgrep) — used for fast searching; must be installed and on PATH.
#
# COMPATIBILITY
#   • Tested on Ubuntu (GNU awk) and macOS (BSD awk). No GNU-specific `date`/`tac`
#     features used. No temporary files created.
#
# EXIT STATUS
#   0  At least one match found (ripgrep success).
#   1  No matches found (ripgrep no-match).
#   >1 Failure (e.g., missing rg, bad arguments, pipeline/IO error).
#
# LIMITATIONS
#   • Assumes headers are exactly of the form `DYYYY-MM-DD` at column 1.
#   • “Last N” is based on physical order in the file, not actual calendar recency.
#   • Very large files are buffered once in awk (lines stored in memory).
#
# TIPS
#   • To change what you search for, pass custom `rg` flags after `--`
#     (e.g., `-- -n --no-heading -C2 -e 'pattern1' -e 'pattern2'`).
#   • For strict header-only output, you can add `-- -e '^D[0-9]{4}-[0-9]{2}-[0-9]{2}$'`.

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

