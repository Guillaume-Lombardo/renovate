# Repository Context

## Purpose

This repository packages a self-hosted Renovate deployment for `gitlab.g1lom.xyz`.

## Remotes

Primary remote: GitLab, configured as `origin`.

Secondary remote: GitHub, configured as `github`, used only for public snapshot tags.

## Snapshot

A snapshot is an annotated Git tag pushed to both GitLab and GitHub. The tag points to the same commit on both remotes.

Publish snapshots with:

```sh
scripts/publish-github-snapshot.sh vYYYY.MM.DD
```

Do not push `main` to GitHub in the normal workflow.
