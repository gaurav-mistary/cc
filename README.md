# Custom Cookiecutter (CC) Engine

Welcome to the `cc` engine. This is a highly opinionated CLI and Git-based templating architecture designed to solve the "Cookiecutter drift" problem.

## The Problem
When you generate a project from a Cookiecutter template, it immediately becomes stale. When you maintain multiple variations of a template (e.g. a base webserver, a webserver with auth, a webserver with a specific database), maintaining the common denominator across all templates is a nightmare of duplication.

## The Solution: Branch-Based Inheritance
Instead of maintaining multiple folders of templates, we use **Git Branches** as the inheritance mechanism. 
- The `main` branch holds the `cc-cli` source code.
- A base technology (like `traefik`) is a branch directly off `main`.
- A feature addition (like adding HTTPS to Traefik) is a child branch off `traefik` called `traefik--secure`.
- By using our `cc cascade` tool, whenever you update the base `traefik` branch, Git automatically merges those changes down into `traefik--secure` and any other hybrid branches!

## The Architecture
We have decoupled the engine from the templates:
1. **`cc` (This Repo)**: CLI engine (`cc-cli`), cascade merges, and the **Docker image** you pull on servers. Optional base branches (`py3.12`, `traefik`, `dockhand`) can sync into the templates repo.
2. **`cc-templates` (Separate Repo)**: Cookiecutter templates for self-hosted services (dockhand, immich, audiobookshelf, vaultwarden, backups, …) plus hybrid branches (`traefik--secure--dockhand`). Hosts `registry.json` for friendly aliases.

```
cc (engine + image)  ──docker push──►  ghcr.io/gaurav-mistary/cc
                                              │
cc-templates (branches)  ◄──cookiecutter clone─┘  (at docker run)
```

Full change log and tree:
- Human guide: [`docs/DOCKER.md`](docs/DOCKER.md)
- Agent hub: [`.agents/knowledge/11-structure-and-changelog.md`](.agents/knowledge/11-structure-and-changelog.md)

## Usage

### Docker (recommended on a server)

Build and push (from this repo), or wait for CI on `main`:

```bash
just docker-build
# Optional local push (after: echo $GITHUB_TOKEN | docker login ghcr.io -u USER --password-stdin)
just docker-push
```

On any server — pull the image, then generate a project from a **cc-templates** branch:

```bash
docker pull ghcr.io/gaurav-mistary/cc:latest

# Alias from registry.json → Cookiecutter clones that branch from cc-templates
docker run --rm -it \
  -v /opt/stacks:/output \
  ghcr.io/gaurav-mistary/cc:latest \
  template create secure-dockhand -o /output

# Exact branch name
docker run --rm -it \
  -v /opt/stacks:/output \
  ghcr.io/gaurav-mistary/cc:latest \
  template create traefik--secure -o /output
```

Defaults baked into the image:
- `TEMPLATES_REPO_URL=https://github.com/gaurav-mistary/cc-templates.git`
- `CC_REGISTRY=…/cc-templates/main/registry.json`

Override with `-e TEMPLATES_REPO_URL=…` if your catalog lives elsewhere.

### The `tc` Just Module
The fastest way to use this system is via the `tc` (Template Create) module loaded in your `justfile`.

```bash
# Generate a project from an alias
just tc new secure-dockhand

# Generate into a specific directory
just tc new secure-dockhand /tmp/my-app
```

### The Registry Mapping
No one wants to type out internal branch names like `traefik--secure--dockhand`. The CLI supports a `registry.json` mapping.

You can host a `registry.json` locally at `~/.cc-registry.json` or host it on GitHub and expose it via a URL:

```json
{
  "secure-dockhand": "traefik--secure--dockhand",
  "web": "traefik--secure"
}
```

Tell the CLI to use it by setting the environment variable in your `.zshrc`:
```bash
export CC_REGISTRY="https://raw.githubusercontent.com/gaurav-mistary/cc-templates/main/registry.json"
```

## Internal CLI Commands (`cc-cli`)
If you want to use the raw CLI instead of the `just tc` wrappers:

```bash
# Cascade merges down the current branch tree
uv run cc-cli cascade

# Mix two branches dynamically in a temporary directory
uv run cc-cli mix py3.12 traefik -o /tmp/mixed-app

# Create a project from a template alias
uv run cc-cli template create secure-dockhand -o /tmp/app
```