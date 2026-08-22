# Changelog: Docker publish + knowledge base (Aug 2026)

This document describes **what changed**, **why**, and **how the final system is structured**. Written for humans and agents resuming the project.

---

## Goals completed in this change set

1. **Agent knowledge base** — persistent docs under `.agents/knowledge/` so work can resume after long gaps.
2. **Clarify two-repo model** — `cc` = engine + Docker image; `cc-templates` = self-hosted service Cookiecutter branches.
3. **Publishable Docker image** — build, push to GHCR, pull on a server, run `template create` so Cookiecutter clones a branch from `cc-templates` onto a mounted volume.

---

## What changed (file by file)

### New files

| Path | Purpose |
|------|---------|
| `.agents/knowledge/INDEX.md` | Hub for all agent knowledge docs |
| `.agents/knowledge/01-vision-and-problem.md` | Why branch inheritance exists |
| `.agents/knowledge/02-architecture.md` | Two-repo model, remotes, flow |
| `.agents/knowledge/03-branch-inheritance.md` | `--` naming, cascade tree rules |
| `.agents/knowledge/04-cli-and-just.md` | Commands and env vars |
| `.agents/knowledge/05-cascade-internals.md` | `cascade.py` algorithm + CI |
| `.agents/knowledge/06-template-anatomy.md` | Cookiecutter layout per branch |
| `.agents/knowledge/07-current-state.md` | Implemented vs planned |
| `.agents/knowledge/08-roadmap.md` | Discussion backlog |
| `.agents/knowledge/09-cc-templates-catalog.md` | Service catalog vision (immich, vaultwarden, …) |
| `.agents/knowledge/10-docker-server-runtime.md` | Pull/run image on servers |
| `.agents/knowledge/11-structure-and-changelog.md` | **This file** |
| `.dockerignore` | Keep image context small (no `.git`, logs, `.agents`, etc.) |
| `.github/workflows/docker-publish.yml` | Push `ghcr.io/gaurav-mistary/cc` on `main` / tags `v*` |

### Modified files

| Path | Change |
|------|--------|
| `Dockerfile` | Prod-default multi-stage build; only copy `cc/` + lockfile; OCI labels; bake `TEMPLATES_REPO_URL` / `CC_REGISTRY` / `FACTORY_URL`; `VOLUME /output`; `ENTRYPOINT ["cc-cli"]` |
| `pyproject.toml` | Add Hatchling `[build-system]` so `uv sync` **installs** the `cc` package (fixes `ModuleNotFoundError: cc` in the image) |
| `uv.lock` | Project source becomes `editable` (required by Hatchling packaging) |
| `justfile` | Image name `ghcr.io/gaurav-mistary/cc`; recipes `docker-build`, `docker-push`, `docker-pull`, `docker-run` |
| `README.md` | Server Docker pull/run section |
| `.env.example` | Document `TEMPLATES_REPO_URL`, `CC_REGISTRY`, `FACTORY_URL` |
| `AGENTS.md` | `cc-templates` catalog + Docker runtime + link to knowledge base |
| `.agents/skills/cookiecutter-engine/SKILL.md` | Point agents at knowledge INDEX |

### Not committed (left local)

| Path | Reason |
|------|--------|
| `cascade_log_*.json` | Runtime artifacts from past cascades |
| `plane-docker-compose.yml` | Scratch / unrelated compose |
| `rename_branches.sh` | One-time migration helper |

---

## Final architecture

```
┌─────────────────────────────────────────────────────────────────┐
│  cc  (this repo — GitHub: gaurav-mistary/cc)                    │
│                                                                 │
│  main branch                                                    │
│  ├── cc/cli.py, cc/cascade.py     CLI engine                    │
│  ├── Dockerfile                   → image build                 │
│  ├── .github/workflows/           cascade.yml + docker-publish  │
│  └── justfile / README            local + server UX             │
│                                                                 │
│  base template branches (optional sync into cc-templates)       │
│  ├── traefik / dockhand / py3.12                                │
│  └── traefik--secure, traefik--dockhand                         │
└────────────────────────────┬────────────────────────────────────┘
                             │ docker build + push
                             ▼
              ghcr.io/gaurav-mistary/cc:latest
                             │
                             │ docker pull / run on any server
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  Server                                                         │
│  docker run -v /opt/stacks:/output ... \                        │
│    template create <alias-or-branch> -o /output                 │
│                                                                 │
│  Container:                                                     │
│  1. Resolve alias via CC_REGISTRY → branch name                 │
│  2. Cookiecutter clones TEMPLATES_REPO_URL @ that branch        │
│  3. Writes project under /output/<project_slug>/                │
└────────────────────────────┬────────────────────────────────────┘
                             │ git clone --branch
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  cc-templates  (GitHub: gaurav-mistary/cc-templates)            │
│                                                                 │
│  main          → registry.json (alias → branch)                 │
│  dockhand, traefik, traefik--secure, …                          │
│  future: immich, audiobookshelf, vaultwarden, backups, …        │
│                                                                 │
│  Each branch root = Cookiecutter template                       │
│  (cookiecutter.json + {{cookiecutter.project_slug}}/)           │
└─────────────────────────────────────────────────────────────────┘
```

### Repo responsibilities

| Repo | Owns | Does **not** own |
|------|------|------------------|
| **`cc`** | CLI, cascade, Docker image, agent docs, optional upstream bases | Everyday service templates (immich, etc.) |
| **`cc-templates`** | All service + hybrid Cookiecutter branches, `registry.json` | The Python CLI source |

### Image contents vs runtime behavior

| Inside the image | At `docker run` time |
|------------------|----------------------|
| Python 3.12 + `cc-cli` + deps | Network needed |
| Default env pointing at `cc-templates` | Cookiecutter **clones** the chosen branch |
| `git` + `ca-certificates` | Output written to mounted `/output` |

Templates are **not** baked into the image — always pulled fresh from GitHub.

---

## Final directory structure (`cc` main)

```
cc/
├── .agents/
│   ├── knowledge/           # Persistent agent docs (01–11)
│   └── skills/
│       └── cookiecutter-engine/SKILL.md
├── .github/workflows/
│   ├── cascade.yml          # Auto-merge children on PR merge
│   └── docker-publish.yml   # Push image to GHCR
├── .dockerignore
├── .env.example
├── AGENTS.md
├── Dockerfile
├── README.md
├── justfile                 # docker-* + mod cc + mod tc
├── cc.just / tc.just
├── pyproject.toml           # hatchling + cc-cli entrypoint
├── uv.lock
└── cc/
    ├── __init__.py
    ├── cli.py               # cascade, init, mix, template create
    └── cascade.py           # recursive parent → child merges
```

---

## How to use the published image

### Build / push (maintainer)

```bash
just docker-build
# Login once: echo $GITHUB_TOKEN | docker login ghcr.io -u gaurav-mistary --password-stdin
just docker-push
```

Or merge/push to `main` and let **Publish Docker image to GHCR** workflow push `ghcr.io/gaurav-mistary/cc:latest`.

After the first CI publish: GitHub → Packages → `cc` → set visibility to **Public** if servers should pull without auth.

### Pull / generate (server)

```bash
docker pull ghcr.io/gaurav-mistary/cc:latest

docker run --rm -it \
  -v /opt/stacks:/output \
  ghcr.io/gaurav-mistary/cc:latest \
  template create secure-dockhand -o /output
```

Override templates origin:

```bash
-e TEMPLATES_REPO_URL=https://github.com/YOU/cc-templates.git \
-e CC_REGISTRY=https://raw.githubusercontent.com/YOU/cc-templates/main/registry.json
```

---

## Packaging fix (important)

Without Hatchling, `uv sync` installed dependencies but **not** the local `cc` package. The container then failed with:

`ModuleNotFoundError: No module named 'cc'`

Fix: `[build-system]` + `[tool.hatch.build.targets.wheel]` in `pyproject.toml`, plus `ENTRYPOINT ["cc-cli"]` and `PYTHONPATH=/app` as belt-and-suspenders.

---

## Related docs

- User-facing: [README.md](../../README.md)
- Agent hub: [INDEX.md](INDEX.md)
- Docker deep dive: [10-docker-server-runtime.md](10-docker-server-runtime.md)
- Catalog vision: [09-cc-templates-catalog.md](09-cc-templates-catalog.md)
