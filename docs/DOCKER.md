# Docker publish & runtime — change log and final structure

This document records **what changed** for the publishable `cc` container image, and how the **final layout** fits together with `cc-templates`.

---

## Why this exists

Goal: on any server, without installing Python/uv:

1. `docker pull` an image built from this repo (`cc`)
2. `docker run … template create <alias-or-branch>`
3. The container clones the matching **Git branch** from **`cc-templates`** and runs Cookiecutter into a mounted host directory

Templates are **not** baked into the image. The image is only the CLI; branches live on GitHub.

---

## What changed (this work)

### New files

| Path | Role |
|------|------|
| `.dockerignore` | Keeps the build context small (no `.git`, cascade logs, `.agents`, secrets). |
| `.github/workflows/docker-publish.yml` | On push to `main` / tags `v*` / manual dispatch: build `BUILD=prod`, push to **GHCR** as `ghcr.io/gaurav-mistary/cc`. |
| `.agents/knowledge/` | Agent knowledge base (vision, architecture, cascade, Docker, roadmap). |
| `docs/DOCKER.md` | This file — human-facing Docker structure & ops guide. |

### Modified files

| Path | Change |
|------|--------|
| `Dockerfile` | Default `BUILD=prod`; copy only `cc/` + metadata; OCI labels; bake `TEMPLATES_REPO_URL` / `CC_REGISTRY` / `FACTORY_URL`; `VOLUME /output`; `ENTRYPOINT ["cc-cli"]`. |
| `pyproject.toml` | Added Hatchling `[build-system]` so `uv sync` **installs** the `cc` package (fixes `ModuleNotFoundError` in the image). |
| `uv.lock` | Project source switched from `virtual` → `editable` after Hatchling. |
| `justfile` | `IMAGE=ghcr.io/gaurav-mistary/cc`; recipes `docker-build`, `docker-push`, `docker-pull`, `docker-run`. |
| `README.md` | Server pull/run section. |
| `.env.example` | Documents `TEMPLATES_REPO_URL`, `CC_REGISTRY`, `FACTORY_URL`. |
| `AGENTS.md` | Docker runtime + link to knowledge base. |
| `.agents/skills/cookiecutter-engine/SKILL.md` | Points at knowledge index. |

### Intentionally not committed

- `cascade_log_*.json` — local cascade run artifacts
- `plane-docker-compose.yml` — scratch compose
- `rename_branches.sh` — one-off migration script (keep local if useful)

---

## Final two-repo structure

```text
┌─────────────────────────────────────┐     ┌──────────────────────────────────────┐
│  cc  (this repo)                    │     │  cc-templates                        │
│  github.com/gaurav-mistary/cc       │     │  github.com/gaurav-mistary/           │
│                                     │     │              cc-templates             │
│  main:                              │     │                                      │
│    cc/cli.py, cc/cascade.py         │     │  Branches = Cookiecutter templates:  │
│    Dockerfile → GHCR image          │     │    traefik, dockhand, immich, …      │
│    just docker-*                    │     │    traefik--secure--dockhand         │
│                                     │     │  main: registry.json (aliases)       │
│  Optional base branches:            │────►│  Cascade hybrids here                │
│    traefik, dockhand, py3.12        │sync │                                      │
└─────────────────────────────────────┘     └──────────────────────────────────────┘
                    │                                          ▲
                    │ docker pull / run                        │
                    ▼                                          │
         ┌──────────────────────┐                              │
         │ ghcr.io/.../cc       │  cookiecutter clone          │
         │ ENTRYPOINT: cc-cli   │──────────────────────────────┘
         │ -v host:/output      │  TEMPLATES_REPO_URL + branch
         └──────────────────────┘
```

### Directory layout of `cc` (engine, `main`)

```text
cc/
├── .agents/
│   ├── knowledge/          # Agent docs (INDEX.md → 01…11)
│   └── skills/
│       └── cookiecutter-engine/SKILL.md
├── .github/workflows/
│   ├── cascade.yml         # Auto-merge children on PR merge
│   └── docker-publish.yml  # Push image to GHCR
├── cc/
│   ├── cli.py              # Typer: cascade, init, mix, template create
│   └── cascade.py          # Branch inheritance merges
├── docs/
│   └── DOCKER.md           # This guide
├── .dockerignore
├── .env.example
├── AGENTS.md
├── Dockerfile
├── README.md
├── justfile                # docker-build / push / pull / run + mod cc + mod tc
├── cc.just
├── tc.just
├── pyproject.toml          # hatchling + cc-cli script
└── uv.lock
```

### Inside the published image

```text
/app/
  .venv/                 # prod deps + installed `cc` package
  cc/                    # source (also on PYTHONPATH)
  pyproject.toml
  README.md
/output/                 # WORKDIR; mount your host stack dir here
ENTRYPOINT: cc-cli
ENV:
  TEMPLATES_REPO_URL=https://github.com/gaurav-mistary/cc-templates.git
  CC_REGISTRY=https://raw.githubusercontent.com/gaurav-mistary/cc-templates/main/registry.json
  FACTORY_URL=… (same default)
```

---

## How generation works at runtime

1. You run: `template create secure-dockhand -o /output`
2. CLI loads `CC_REGISTRY` → resolves alias → e.g. `traefik--secure--dockhand`
3. Cookiecutter runs: clone `TEMPLATES_REPO_URL`, checkout that branch
4. Project files land under `/output/<project_slug>/` (your host mount)

No templates are stored in the image layers.

---

## Operator commands

### Maintainers (this machine / CI)

```bash
just docker-build          # tags ghcr.io/gaurav-mistary/cc:latest (+ cc:latest)
just docker-push           # needs: docker login ghcr.io

# CI also pushes on every push to main (and tags v*)
```

### Servers

```bash
docker pull ghcr.io/gaurav-mistary/cc:latest

docker run --rm -it \
  -v /opt/stacks:/output \
  ghcr.io/gaurav-mistary/cc:latest \
  template create secure-dockhand -o /output
```

After the **first** GHCR publish: GitHub → Packages → `cc` → set visibility to **Public** if servers should pull without a token.

Image: `ghcr.io/gaurav-mistary/cc:latest` (multi-arch: `linux/amd64` + `linux/arm64`).

Package page: https://github.com/gaurav-mistary/cc/pkgs/container/cc


### Private `cc-templates`

```bash
docker run --rm -it \
  -v /opt/stacks:/output \
  -v "$HOME/.ssh:/root/.ssh:ro" \
  -e TEMPLATES_REPO_URL=git@github.com:YOU/cc-templates.git \
  ghcr.io/gaurav-mistary/cc:latest \
  template create immich -o /output
```

---

## Related agent docs

| Doc | Topic |
|-----|--------|
| [`.agents/knowledge/INDEX.md`](../.agents/knowledge/INDEX.md) | Knowledge hub |
| [09-cc-templates-catalog.md](../.agents/knowledge/09-cc-templates-catalog.md) | Service catalog repo |
| [10-docker-server-runtime.md](../.agents/knowledge/10-docker-server-runtime.md) | Shorter Docker runtime notes |
| [02-architecture.md](../.agents/knowledge/02-architecture.md) | Two-repo model |
