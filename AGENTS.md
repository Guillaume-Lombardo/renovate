# Agent Instructions

This repository contains a self-hosted Renovate deployment for GitLab.

These instructions apply to Codex, OpenCode, and other agents that read `AGENTS.md`.

## Repository Rules

- Treat `origin` as the GitLab primary remote.
- Treat `github` as the GitHub snapshot-controlled remote.
- Push normal branches and `main` only to GitLab.
- Do not manually push `main` to GitHub in the normal workflow.
- Publish GitHub snapshots only with `scripts/publish-github-snapshot.sh`.
- Keep secrets in `.env`; never commit `.env`.

## Skills

Use `skills/devops/github-snapshot-release/SKILL.md` when publishing a GitHub snapshot tag.

List or link repository skills with:

```sh
scripts/list-skills.sh
scripts/link-agent-skills.sh codex
scripts/link-agent-skills.sh opencode
```

## Validation

Before changing operational files, run the narrowest relevant validation:

```sh
sh -n scripts/*.sh
shellcheck scripts/*.sh
node --check config.js
renovate-config-validator --no-global renovate.json
renovate-config-validator config.js
```
