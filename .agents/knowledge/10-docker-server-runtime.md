# Docker Image — Pull on Server, Generate Projects

## Goal

Run a **single container** on any server (no local Python/uv install) that:

1. Clones/checks out a branch from **`cc-templates`** (via GitHub URL)
2. Runs **Cookiecutter** to emit a project directory
3. Writes output to a **mounted volume**

The branch is selected by alias (`registry.json`) or by exact branch name.

## What exists

| Piece | Status |
|-------|--------|
| `Dockerfile` (prod multi-stage) | ✅ |
| `.dockerignore` | ✅ |
| GHCR publish workflow | ✅ `.github/workflows/docker-publish.yml` |
| Image | `ghcr.io/gaurav-mistary/cc` |
| Defaults: `TEMPLATES_REPO_URL` + `CC_REGISTRY` | ✅ baked into image |

## Build & push (maintainer)

```bash
just docker-build          # tags ghcr.io/gaurav-mistary/cc:latest and cc:latest
just docker-push           # after docker login ghcr.io

# Or let CI push on every push to main / tag v*
```

CI: on `main` and tags `v*`, builds with `BUILD=prod` and pushes to GHCR.

**First-time GHCR:** after the first push, set the package visibility to **Public** under GitHub → Packages if you want anonymous `docker pull` on servers.

## Run on a server

```bash
docker pull ghcr.io/gaurav-mistary/cc:latest

docker run --rm -it \
  -v /opt/stacks:/output \
  ghcr.io/gaurav-mistary/cc:latest \
  template create secure-dockhand -o /output
```

Cookiecutter (inside the container) clones `TEMPLATES_REPO_URL` at the resolved branch and writes under `/output`.

### Override templates origin

```bash
docker run --rm -it \
  -v /opt/stacks:/output \
  -e TEMPLATES_REPO_URL=https://github.com/YOU/cc-templates.git \
  -e CC_REGISTRY=https://raw.githubusercontent.com/YOU/cc-templates/main/registry.json \
  ghcr.io/gaurav-mistary/cc:latest \
  template create immich -o /output
```

### Private templates (SSH)

```bash
docker run --rm -it \
  -v /opt/stacks:/output \
  -v "$HOME/.ssh:/root/.ssh:ro" \
  -e TEMPLATES_REPO_URL=git@github.com:YOU/cc-templates.git \
  ghcr.io/gaurav-mistary/cc:latest \
  template create immich -o /output
```

Local helper: `just docker-run /opt/stacks template create dockhand -o /output`

## Environment variables

| Variable | Default in image | Purpose |
|----------|------------------|---------|
| `TEMPLATES_REPO_URL` | `https://github.com/gaurav-mistary/cc-templates.git` | Git origin for template branches |
| `CC_REGISTRY` | raw URL to `registry.json` | Alias → branch map |
| `FACTORY_URL` | same as templates URL | Used by `init` / `mix` |
