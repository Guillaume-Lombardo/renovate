# GitHub Snapshot Policy

GitLab is the primary remote and receives normal branch pushes.

GitHub is the secondary remote for public snapshots only. Its `main` branch exists, but it is advanced only by the snapshot workflow.

Configure the GitHub remote with:

```sh
scripts/setup-github-snapshot-remote.sh
```

Publish a snapshot with:

```sh
scripts/publish-github-snapshot.sh vYYYY.MM.DD
```

The script verifies:

- The working tree is clean.
- The current branch is `main`.
- `origin/main` points to the current commit.
- The `github` remote points to `https://github.com/Guillaume-Lombardo/renovate.git`.
- Existing `github/main`, when present, is an ancestor of the current commit.
- The tag does not already exist locally or on either remote.

It then creates one annotated tag, pushes that tag to GitLab, and pushes both `main` and the tag to GitHub. Normal branch work still goes to GitLab only.
