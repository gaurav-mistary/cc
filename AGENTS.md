# Custom Cookiecutter (CC) Architecture

## Overview
This repository (`cc`) is the engine for a highly opinionated, hierarchical Cookiecutter templating system based on **Git branch inheritance**.

### Core Concepts:
1. **The CLI Engine**: The `main` branch contains `cc-cli`, a custom Python tool built with Typer to orchestrate Cookiecutter and Git.
2. **The Base Templates**: Branches directly off `main` (e.g., `traefik`, `dockhand`, `py3.12`) contain base Cookiecutter template directories.
3. **The Registry & Templates Repo**: **`cc-templates`** is a separate repository holding Docker Cookiecutter templates for every self-hosted service (dockhand, immich, audiobookshelf, vaultwarden, backups, etc.) plus composed hybrid branches. Friendly aliases map to branch names via `registry.json`.
4. **The Cascade**: Updates made to `main` cascade down to base branches. Updates made to base branches cascade down to hybrid template branches.
5. **Docker runtime**: The `cc` image can be pulled on a server; run the container with a volume mount to generate projects from any `cc-templates` branch via `TEMPLATES_REPO_URL`.

## The CLI Tool (`cc-cli`)
The CLI orchestrates everything.
- **`cc-cli template create <alias>`**: Reads a `registry.json` (from URL or `~/.cc-registry.json`), resolves the alias to a branch name, and runs `cookiecutter` against the templates repository.
- **`cc-cli cascade`**: Analyzes the git tree. If `traefik` is updated, it automatically merges the new `traefik` into `traefik--secure` and `traefik--dockhand`.

## Task Runner (`just`)
- **`just cc cascade`**: Triggers the cascade merge.
- **`just tc <alias>`**: Fast wrappers for `cc-cli template create`. (e.g., `just tc secure-dockhand`). Defaults output to `~/projects/study`.

## Workflow
1. Develop base technologies in the `cc` repository (e.g. update Traefik to v4).
2. Sync the `cc-templates` fork.
3. Run `just cc cascade` in the fork to auto-merge Traefik v4 into all your hybrid branches.
4. Users run `just tc <alias>` to scaffold projects.

## Agent knowledge base

Detailed context for AI agents lives in **`.agents/knowledge/`** — start at [INDEX.md](.agents/knowledge/INDEX.md).

Cursor skill: `.agents/skills/cookiecutter-engine/SKILL.md`
