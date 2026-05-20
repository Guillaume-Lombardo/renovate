# ADR 0001: GitLab Primary Remote And GitHub Snapshot Remote

## Status

Accepted.

## Context

This repository is developed on GitLab, but a GitHub repository is useful for public or cross-tool access.

Pushing every GitLab `main` commit to GitHub would make GitHub look like a full mirror. That is not the intended contract: GitHub should expose selected repository states only.

## Decision

`origin` remains the primary GitLab remote:

```text
https://gitlab.g1lom.xyz/g1lom/renovate.git
```

`github` is the secondary snapshot remote:

```text
https://github.com/Guillaume-Lombardo/renovate.git
```

GitHub has a `main` branch, but it is snapshot-controlled. Normal branch work is pushed to GitLab only; `github/main` is advanced only by the snapshot script.

Snapshots are published with:

```sh
scripts/publish-github-snapshot.sh vYYYY.MM.DD
```

## Consequences

- GitHub `main` is updated only at snapshot publication time.
- Snapshot tags on GitLab and GitHub point to the same commit.
- Agents and humans must not manually use `git push github main` for the normal workflow.
- The publishing script is the canonical path for GitHub updates.
