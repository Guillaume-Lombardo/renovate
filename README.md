# Renovate Bot

Self-hosted Renovate deployment for `gitlab.g1lom.xyz`, packaged for Docker Compose and suitable for a Dockhand Git deployment.

## Security model

- The GitLab PAT is read from `.env` and is never committed.
- Autodiscovery is enabled but restricted by `RENOVATE_AUTODISCOVER_FILTER` because the bot account has broad permissions.
- The container does not mount the Docker socket.
- The Renovate config and runner script are baked into the published registry image, avoiding runtime bind mounts to relative host paths.
- Linux capabilities are dropped and `no-new-privileges` is enabled. `CAP_CHOWN` is added back only so the startup wrapper can repair ownership on the persistent Renovate cache volume before dropping to the non-root Renovate user.
- Renovate runs periodically from a small shell wrapper instead of relying on a tight restart loop.
- Before each Renovate run, an optional GitLab member sync can add `renovate-bot` to all projects owned by `GITLAB_PROJECT_OWNER`.

## Setup

1. Create the runtime environment file:

   ```sh
   cp .env.example .env
   ```

2. Fill in `RENOVATE_TOKEN` with the PAT for `renovate-bot`.

3. To let the container add `renovate-bot` as a member before each Renovate run, fill in:

   ```sh
   GITLAB_ADMIN_TOKEN=...
   GITLAB_RENOVATE_BOT_USER_ID=...
   ```

   The sync defaults to projects owned by `g1lom` on `https://gitlab.g1lom.xyz` and grants Developer access (`GITLAB_RENOVATE_ACCESS_LEVEL=30`). If either variable is empty, the sync is skipped.

4. Adjust `RENOVATE_AUTODISCOVER_FILTER` if needed. The default is:

   ```sh
   RENOVATE_AUTODISCOVER_FILTER=g1lom/*
   ```

5. Adjust `RENOVATE_GIT_AUTHOR` if needed. The default is:

   ```sh
   RENOVATE_GIT_AUTHOR="Renovate Bot <plain.rose9051@fastmail.com>"
   ```

6. Adjust GitLab notification targets if needed. By default, Renovate assigns and requests review from `g1lom` on merge requests, and mentions `@g1lom` in Dependency Dashboard issues:

   ```sh
   RENOVATE_ASSIGNEES=g1lom
   RENOVATE_REVIEWERS=g1lom
   RENOVATE_DASHBOARD_MENTIONS=g1lom
   ```

   Use comma-separated usernames for multiple people. Set a variable to an empty value to disable that list.

7. Start the bot:

   ```sh
   docker compose up -d
   ```

8. Inspect logs:

   ```sh
   docker compose logs -f renovate
   ```

## CI

GitLab CI validates project metadata before building the image:

- YAML files with `yamllint`.
- JSON files with Node's JSON parser.
- Dockerfiles with `hadolint`.
- Compose files with `docker compose config --quiet`.
- Renovate configuration with `renovate-config-validator`.
- Shell scripts with `sh -n` and `shellcheck`.

After validation succeeds on the default branch, the CI builds and pushes the image to the project container registry:

```sh
registry.g1lom.xyz/g1lom/renovate:latest
registry.g1lom.xyz/g1lom/renovate:<commit-sha>
```

## GitHub snapshots

GitLab is the primary remote (`origin`) and receives normal branch pushes.

GitHub is a secondary snapshot-controlled remote:

```text
github  https://github.com/Guillaume-Lombardo/renovate.git
```

Configure or verify the remote with:

```sh
scripts/setup-github-snapshot-remote.sh
```

Publish a GitHub snapshot from `main` with:

```sh
scripts/publish-github-snapshot.sh vYYYY.MM.DD
```

The script creates one annotated tag, pushes that tag to both GitLab and GitHub, and advances `github/main` to the snapshot commit. Do not push `main` to GitHub outside this script. See `docs/snapshot-policy.md` and `docs/adr/0001-gitlab-primary-github-snapshot-remote.md`.

The repository also includes a compatible skill for Codex, Claude, and OpenCode:

```sh
scripts/list-skills.sh
scripts/link-agent-skills.sh codex
scripts/link-agent-skills.sh claude
scripts/link-agent-skills.sh opencode
```

## Repository onboarding

Renovate is configured with `requireConfig: optional`, so repositories without a Renovate config can receive an onboarding merge request. Once accepted, repository-specific behavior should live in that repository's `renovate.json`.

## Supported update targets

Renovate auto-detects supported files. This deployment is especially intended for:

- Docker images in `Dockerfile` and Compose files.
- Python dependencies in common files such as `requirements.txt`, `pyproject.toml`, Poetry, Pipenv, and setup metadata.

Non-major Docker and Python updates are grouped to keep merge request volume manageable.

## Dependency Dashboard workflow

The Dependency Dashboard issue is the control surface for updates that need manual approval. If you tick checkboxes there, leave the issue open until Renovate has run again and created the corresponding merge requests. Closing the issue early can make the checked items harder to track, and Renovate may create a new dashboard issue later if updates are still pending.

Once the merge requests are open, you can close the dashboard issue manually if you do not want to keep it as a tracking view. Keeping it open is usually more useful, because Renovate updates it with pending, open, blocked, and completed work.
