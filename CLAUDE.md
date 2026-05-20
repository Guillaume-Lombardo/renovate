# Claude Code Usage

This repository can be used directly by Claude Code.

Claude should follow `AGENTS.md` for repository-wide rules and use `skills/devops/github-snapshot-release/SKILL.md` for GitHub snapshot releases.

The GitHub remote is snapshot-controlled. Do not manually push `main` to GitHub in the normal workflow.

To expose repository skills to Claude Code:

```sh
scripts/link-agent-skills.sh claude
```
