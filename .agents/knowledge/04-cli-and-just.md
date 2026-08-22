# CLI and Just Reference

## Installation / dev

```bash
uv sync                    # install deps + cc-cli entrypoint
uv run pre-commit run --all-files
```

Entry point: `cc-cli` → `cc.cli:main` (also `uv run python -m cc.cli`).

## Just modules

| Command | Maps to |
|---------|---------|
| `just cc cascade` | `uv run python -m cc.cli cascade` |
| `just cc run <args>` | raw `cc.cli` passthrough |
| `just tc new <alias> [dir]` | `template create` → default `~/projects/study` |
| `just tc secure-dockhand` | shortcut alias |
| `just tc webserver` | shortcut alias |
| `just docker-build [dev\|prod]` | Docker image `cc:latest` |
| `just docker-run <mount> <args>` | run container with SSH/gitconfig mounts |

## Commands

### `cc-cli cascade`

Merge current branch into all direct children recursively. See [05-cascade-internals.md](05-cascade-internals.md).

### `cc-cli init [template]`

Generate from a branch in `FACTORY_URL` repo.

```bash
cc-cli init traefik -o /tmp/out --repo $FACTORY_URL
cc-cli init --pyv 3.12 -o /tmp/out --repo $FACTORY_URL          # branch py3.12
cc-cli init cli --pyv 3.12 -o /tmp/out --repo $FACTORY_URL        # branch py3.12--cli
cc-cli init ... --push-url git@github.com:user/new-repo.git       # init git + push
```

Wraps: `cookiecutter <repo> --checkout <branch> --output-dir <dir>`

### `cc-cli mix <base> <mixin>`

Ad-hoc merge without persisting a branch:

1. Clone repo to temp dir
2. Checkout `base`, merge `origin/{mixin}`
3. On conflict → abort with instructions to create `{base}--{mixin}` manually
4. On success → `cookiecutter <temp_dir>`

### `cc-cli template create <alias>`

Primary user-facing generator. Resolves alias via registry, then cookiecutters from `TEMPLATES_REPO_URL`.

```bash
cc-cli template create secure-dockhand -o ~/projects/study
cc-cli template create secure-dockhand -o /tmp/app project_slug=my-app   # extra cookiecutter args
cc-cli template create traefik--secure --registry ~/.cc-registry.json
```

Defaults:
- `--repo` → `https://github.com/gaurav-mistary/cc-templates.git`
- `--registry` → `~/.cc-registry.json` (or `CC_REGISTRY` env)

## Docker

```bash
just docker-build prod
just docker-run ~/projects/study init traefik -o /output --repo ...
```

Container entrypoint: `python -m cc.cli` — pass subcommands as args.

## Dependencies (pyproject.toml)

- `cookiecutter>=2.7.1` — project generation
- `gitpython>=3.1.52` — cascade merges
- `typer`, `loguru`, `python-dotenv`, `rust-just`
