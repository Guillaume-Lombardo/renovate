# Repository Context

## Purpose

This repository packages a self-hosted Renovate deployment for `gitlab.g1lom.xyz`.

## Remotes

Primary remote: GitLab, configured as `origin`.

Secondary remote: GitHub, configured as `github`, used only for public snapshots. Its `main` branch is synthetic and contains one commit per snapshot.

## Snapshot

A snapshot is an annotated Git tag on GitLab and a synthetic commit on GitHub. Both remotes expose the same tag name and repository tree, but GitHub does not receive the full GitLab history.

Publish snapshots with:

```sh
scripts/publish-github-snapshot.sh vYYYY.MM.DD
```

Do not manually push `main` to GitHub in the normal workflow.
