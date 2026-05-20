# Repository Context

## Purpose

This repository packages a self-hosted Renovate deployment for `gitlab.g1lom.xyz`.

## Remotes

Primary remote: GitLab, configured as `origin`.

Secondary remote: GitHub, configured as `github`, used only for public snapshots.

## Snapshot

A snapshot is an annotated Git tag pushed to both GitLab and GitHub. The tag points to the same commit on both remotes, and `github/main` is advanced to that commit.

Publish snapshots with:

```sh
scripts/publish-github-snapshot.sh vYYYY.MM.DD
```

Do not manually push `main` to GitHub in the normal workflow.
