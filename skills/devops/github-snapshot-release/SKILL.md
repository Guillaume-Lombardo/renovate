---
name: github-snapshot-release
description: Use when publishing a Renovate repository snapshot to GitHub by advancing github/main and pushing an annotated tag.
license: MIT
compatibility: codex, claude, opencode
metadata:
  category: devops
---

# GitHub Snapshot Release

Use this skill when the user asks to publish or prepare a GitHub snapshot for this repository.

## Workflow

1. Read `docs/snapshot-policy.md`.
2. Verify the GitHub remote with `scripts/setup-github-snapshot-remote.sh`.
3. Confirm the repository is on `main`, clean, and up to date with `origin/main`.
4. Publish the snapshot with `scripts/publish-github-snapshot.sh vYYYY.MM.DD`.
5. Verify the tag exists on both remotes with `git ls-remote --tags origin <tag>` and `git ls-remote --tags github <tag>`.
6. Verify `github/main` points to the snapshot commit with `git ls-remote --heads github main`.

Never manually push `main` to GitHub in the normal workflow.
