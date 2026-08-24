# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

This is a monorepo of independently versioned, independently released Docker images (`docker/`) and Helm charts (`helm/`) used for internal infra tooling (backups, GitHub Actions runners, cluster utilities, a proxy, a git hook runner, PostgreSQL setup). There is no shared application code or build system across packages — each subdirectory under `docker/` or `helm/` is a self-contained unit.

## Release model (CI/CD)

Releases are driven entirely by `.github/workflows/build.yml` on push to `main` or `dev`:

1. It diffs changed files and buckets them into `docker/<image>/...` and `helm/<chart>/...` paths.
2. Each changed image directory triggers `.github/workflows/_docker.yml`; each changed chart directory triggers `.github/workflows/_helm.yml`.
3. **Every docker image must have a `VERSION.txt`** at its root containing the semver to tag — the workflow reads this file directly and fails the build if it's missing. Bump it manually as part of any change to that image.
4. Environment resolution: `main` → `production` (publishes to Docker Hub under `kluvtad/<image>`, tags with semver + semver-shortsha + `main` + `latest`), any other branch (e.g. `dev`) → publishes to `ghcr.io/<repo>/docker/<image>` tagged `<branch>-<semver>`.
5. Helm charts follow the same production/dev split but push OCI packages (`helm push`) to Docker Hub (prod) or GHCR (dev), and additionally maintain a Helm repo index by committing to `docs/charts/stable/index.yaml` (main) or `docs/charts/dev/index.yaml` (other branches) — served via GitHub Pages from `docs/`. The workflow refuses to push a chart version that already exists in the index, so **bump `version:` in `Chart.yaml`** for any chart change.
6. On production releases, a git tag is pushed (`docker/<image>/<semver>` or `helm/<chart>/<semver>-helm`) and a Telegram notification is sent via `_notification.yml`.

Implication for making changes: touching a file under `docker/foo/` only ever affects the `foo` image's release; it will not rebuild sibling images. Same isolation applies per-chart under `helm/`.

## `docker/` packages

Each image is a standalone Dockerfile + support files; no shared base image between them. Notable ones:

- **`backup-tooltoy/`** — a [Task](https://taskfile.dev) (`go-task`) driven backup tool, entrypoint `task run`. Architecture is a two-axis plugin system composed via `Taskfile.yaml`:
  - **Database backends** (`databases/*.taskfile.yml`, selected via required `DB_TYPE` var: `postgresql` | `sealedSecrets` | `pvc`) each implement a `backup` task that dumps into `{{.BACKUP_DIR}}`.
  - **Storage backends** (`storages/*.taskfile.yml`: `gcs`, `s3`) each implement an `upload` task, selected at runtime by iterating every file in `storage-env-files/` — the storage type is inferred from the filename prefix before the first `-` (e.g. `gcs-test.env` → `gcs` backend), and each file is sourced as the env for that upload.
  - To add a new storage target, drop a new `<type>-<name>.env` file into `storage-env-files/`; to add a new storage/database backend, add a taskfile under `storages/`/`databases/` and register it in the respective `Taskfile.yml` include.
  - Local dev: `docker compose up` from within `docker/backup-tooltoy/`.
- **`postgresql-setup/`** — Ansible-driven (via `alpine/ansible`), entrypoint `entrypoint.sh` running `playbook.yml` against `inventory/`, roles under `roles/`.
- **`githook/`** — Python entrypoint (`entrypoint.sh` → `main.py`), config-driven via `config/`.
- **`github-runner/`** — self-hosted GitHub Actions runner image with `kubectl`, `helm` (+ `helm-diff` plugin), `yq` preinstalled, runs as non-root `runner` user.
- **`tinyproxy/`** — tinyproxy built from source, runs as non-root `nonroot` user.
- **`cluster-disaster/`** — Python + Task + kubectl utility, entrypoint `python main.py`.
- **`busybox/`** — general debug/toolbox image (mysql/psql/redis-cli/kubectl clients) plus a small `app.py`.

## `helm/` charts

Standard Helm chart layout per chart (`Chart.yaml`, `values.yaml`, `templates/`). `helm/common` is a **library chart** (no deployable templates) providing shared template helpers (`_helpers.tpl`, `_configmap.tpl`, `_sealed-secret.tpl`) intended to be pulled in as a chart dependency by the others (see the commented-out `dependencies:` block in `helm/postgresql-ha/Chart.yaml` for the pattern — repository is the GitHub Pages chart repo published from `docs/charts/stable`).

Common local commands:
```bash
helm lint helm/<chart>
helm template helm/<chart>
helm dep up helm/<chart>   # required before packaging if it declares dependencies
```

## Other directories

- `docs/` — GitHub Pages source (Jekyll, see `docs/ _config.yml`) publishing the Helm chart repo index (`docs/charts/stable/index.yaml`, `docs/charts/dev/index.yaml`); these index files are updated by CI (`_helm.yml`), not by hand.
- `.bruno/` — Bruno API collection for manually testing the Telegram bot notification endpoints used by `_notification.yml` (`getUpdates`, `sendMessage`), against env vars in `.bruno/environments/kluvtad.bru`.
- `.github/workflows/lib/parse_template.go` — standalone Go helper used by the notification workflow to render Go `text/template` message bodies.
- `tmp/` — scratch/output directory, not source.

## Conventions when modifying a package

- Bump `docker/<image>/VERSION.txt` for any docker image change, and `version:` in `helm/<chart>/Chart.yaml` for any chart change — CI will fail otherwise (missing VERSION.txt) or reject the push (duplicate chart version already in the index).
- Keep changes scoped to one `docker/<x>/` or `helm/<x>/` directory per logical change where possible, since CI fans out per-directory.
