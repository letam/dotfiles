# Claude Code config

Backed-up copies of `~/.claude/` files. Restore after a reformat:

```sh
mkdir -p ~/.claude
cp ~/code/dotfiles/.config/claude/settings.json  ~/.claude/settings.json
cp ~/code/dotfiles/.config/claude/statusline.sh  ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
```

## Prerequisites

- `brew install starship jq` — Starship for the prompt, jq for parsing the
  session JSON Claude Code passes on stdin.
- Starship config lives in `~/.config/starship.toml` (separate dotfile).

## What the status line shows

`statusline.sh` runs Starship (with `STARSHIP_SHELL=` so it emits raw ANSI
instead of zsh `%{%}` wrappers), strips the trailing prompt-character line,
then appends `[ctx <tokens>k · <pct>%]` computed from the latest message
usage in the session transcript. Colors: green <50%, yellow 50–79%, red 80%+.
