#!/bin/bash
# Claude Code statusLine: Starship prompt + context token usage.
# Reads session JSON on stdin, finds the latest message usage in the
# transcript, and appends a "[ctx Nk / 1M]" suffix.

input=$(cat)
transcript=$(printf '%s' "$input" | jq -r '.transcript_path // ""')

tokens=0
if [[ -n "$transcript" && -f "$transcript" ]]; then
  tokens=$(tail -n 200 "$transcript" 2>/dev/null | jq -s '
    [.[] | select(.message.usage)] | last | .message.usage |
    ((.input_tokens // 0) + (.cache_read_input_tokens // 0) + (.cache_creation_input_tokens // 0))
  ' 2>/dev/null)
  [[ -z "$tokens" || "$tokens" == "null" ]] && tokens=0
fi

prompt=$(STARSHIP_SHELL= /usr/local/bin/starship prompt | awk 'NF' | sed '$d' | tr '\n' ' ')

if (( tokens > 0 )); then
  label=$(awk -v t="$tokens" 'BEGIN { if (t >= 1000) printf "%.1fk", t/1000; else printf "%d", t }')
  pct=$(awk -v t="$tokens" 'BEGIN { printf "%d", (t*100)/1000000 }')
  # Color: green <50%, yellow <80%, red >=80%
  if (( pct >= 80 )); then color=$'\033[31m'
  elif (( pct >= 50 )); then color=$'\033[33m'
  else color=$'\033[32m'
  fi
  printf '%s %s[ctx %s · %d%%]\033[0m' "$prompt" "$color" "$label" "$pct"
else
  printf '%s' "$prompt"
fi
