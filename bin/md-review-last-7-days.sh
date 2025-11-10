#!/usr/bin/env bash

# Print dates and checkboxes and timestamps of last N dates

file=$1
N=$2
awk -v N="$N" '
  /^D[0-9]{4}-[0-9]{2}-[0-9]{2}/ { idx[++c]=NR }
  { buf[NR]=$0 }
  END {
    start = (c>=N ? idx[c-N+1] : 1)
    for (i=start; i<=NR; i++) print buf[i]
  }
' "$file" | rg -n --no-heading -e '- \[ \]' -e '^D[0-9]{4}-[0-9]{2}-[0-9]{2}' -e 'T[0-9]{2}:[0-9]{2}'
# to not print line numbers
# ' "$file" | rg -N --multiline --no-heading -e '- \[ \]' -e '^D[0-9]{4}-[0-9]{2}-[0-9]{2}' -e 'T[0-9]{2}:[0-9]{2}'

