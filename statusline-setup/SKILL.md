---
name: statusline-setup
description: Install the Claude Code statusline script and wire it into settings.json. Triggers on: "statusline-setup", "/statusline-setup", "install statusline", "setup statusline", "configure statusline".
---

Install the Claude Code statusline script. Follow these steps exactly:

## Step 1 — Locate skill repo (silent)

Find the `scripts/statusline-command.sh` file in the dot-skills repo.
Expected path: `~/projects/dot-skills/scripts/statusline-command.sh`

If missing, tell the user and stop.

## Step 2 — Copy script

```bash
cp ~/projects/dot-skills/scripts/statusline-command.sh ~/.claude/statusline-command.sh
```

## Step 3 — Wire into settings.json

Target file: `~/.claude/settings.json`

Read the file, then add or update the `statusLine` key:

```json
"statusLine": {
  "type": "command",
  "command": "bash /Users/YOU/.claude/statusline-command.sh"
}
```

Replace `YOU` with the actual username from `whoami` or `$HOME`.

If `settings.json` already has a `statusLine` key — show the current value and ask the user before overwriting.

## Step 4 — Confirm

Print:
```
✓ Copied → ~/.claude/statusline-command.sh
✓ settings.json → statusLine configured
→ Restart Claude Code to activate.
```
