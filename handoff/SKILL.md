---
name: handoff
description: Save session context for later resumption. Writes summary to ~/.claude/summaries/ and updates .claude/handoff.md in the project root (git root or cwd). Run before /clear. Triggers on: "handoff", "/handoff", "save session", "save context".
---

Save current session context for later resumption. Follow these steps exactly:

## Step 1 — Determine project root (silent)

Run in parallel:
- `git rev-parse --show-toplevel 2>/dev/null || pwd` — project root
- `git diff HEAD --stat 2>/dev/null` — files changed
- `git log --oneline -5 2>/dev/null` — recent commits
- `git status --short 2>/dev/null` — uncommitted changes

PROJECT_ROOT = git root if available, else cwd.
HANDOFF_FILE = "$PROJECT_ROOT/.claude/handoff.md"

Create `.claude/` dir if missing: `mkdir -p "$PROJECT_ROOT/.claude"`

## Step 2 — Write summary to ~/.claude/summaries/

Save `~/.claude/summaries/YYYY-MM-DD_HH-MM.md`:

```
## Session Summary — {DATE}

**Project:** {basename of PROJECT_ROOT}
**Root:** {PROJECT_ROOT}

### Goal
{1-2 sentences: what the user was trying to accomplish}

### Done
{bullet list of completed work}

### Key Decisions
{bullet list of non-obvious choices and why}

### Files Changed
{from git diff --stat, or "no git repo"}

### Uncommitted Changes
{from git status, or "clean"}

### Next Steps
{what logically comes next}
```

## Step 3 — Update handoff file

Write `$HANDOFF_FILE` (overwrite if exists):

```
root: {PROJECT_ROOT}
updated: {YYYY-MM-DD HH:MM}
---
{3-5 sentences: what was done, key decisions, what's next. Dense, no filler.}
```

## Step 4 — Print confirmation

```
✓ Summary → ~/.claude/summaries/{filename}
✓ Handoff → {HANDOFF_FILE}
→ Run /clear. Next session in this directory: /takeover to resume.
```

Keep handoff body under 100 tokens.
