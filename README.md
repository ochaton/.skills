# .skills

Custom skills for [Claude Code](https://claude.ai/code).

## Install

```bash
# Clone into ~/.claude/skills/ (or symlink)
git clone git@github.com:ochaton/.skills.git ~/.claude/skills
```

Or add individual skill directories to `~/.claude/skills/`.

## Skills

| Skill | Description |
|-------|-------------|
| `advanced-go` | Pedantic Go reviewer & writer. Enforces correctness, performance, minimalism, modern idiomatic Go (1.22+). Triggers automatically on any `.go` file. |
| `handoff` | Save session context before `/clear`. Writes summary + project handoff file. |
| `takeover` | Resume previous session. Reads project handoff file and restores context. |
