---
name: takeover
description: Resume a previous session in the current directory. Reads .claude/handoff.md from the project root (git root or cwd) and loads its context. Triggers on: "takeover", "/takeover", "resume", "resume project", "what was I working on".
---

Resume the previous session for this project. Follow these steps exactly:

## Step 1 — Find handoff file (silent)

Run: `git rev-parse --show-toplevel 2>/dev/null || pwd`

PROJECT_ROOT = result above.
HANDOFF_FILE = "$PROJECT_ROOT/.claude/handoff.md"

Check: `test -f "$HANDOFF_FILE" && echo exists || echo missing`

If missing: say "No handoff found for {PROJECT_ROOT}. Start fresh or run /handoff at end of a session." Stop here.

## Step 2 — Load and present context

Read `$HANDOFF_FILE`. Print:

```
## Resuming: {basename(PROJECT_ROOT)}
Last saved: {updated line}

{full handoff body}

Ready. What's next?
```

Then wait for user instruction. Do NOT start working without instruction.
