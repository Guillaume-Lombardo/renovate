# GitHub Snapshot Policy

GitLab is the primary remote and receives normal branch pushes.

GitHub is the secondary remote for public snapshots only. Its `main` branch is a synthetic snapshot history: each commit on `github/main` represents one published snapshot tree.

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

It then:

- Creates an annotated tag on the real GitLab `main` commit and pushes it to GitLab.
- Creates a synthetic GitHub snapshot commit from the same tree.
- Pushes that synthetic commit to `github/main`.
- Pushes the GitHub tag to that synthetic commit.

Normal branch work still goes to GitLab only. Do not push GitLab history to GitHub.
