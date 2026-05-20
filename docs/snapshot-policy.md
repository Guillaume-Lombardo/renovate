# GitHub Snapshot Policy

GitLab is the primary remote and receives normal branch pushes.

GitHub is the secondary remote for public snapshots only. The `main` branch is not pushed to GitHub in the normal workflow.

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
- The tag does not already exist locally or on either remote.

It then creates one annotated tag and pushes the same tag to GitLab and GitHub. It never pushes the `main` branch to GitHub.
