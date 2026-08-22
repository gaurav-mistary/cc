# Template Anatomy (per branch)

Each template branch must be a **valid Cookiecutter template** at its root.

## Required layout

```
cookiecutter.json
{{cookiecutter.project_slug}}/
  ... project files ...
```

CLI docstring (`template create`) states this explicitly. Cookiecutter clones the branch and expects standard structure.

## Branch content vs `main`

| Branch | Typical contents |
|--------|------------------|
| `main` | Python package `cc/`, tooling, docs — **not** a cookiecutter template |
| `traefik` | Traefik docker-compose, labels, networks |
| `dockhand` | Dockhand admin UI stack files |
| `py3.12` | Python 3.12 project skeleton (Dockerfile, pyproject, etc.) |
| `traefik--secure` | Traefik base + TLS/Let's Encrypt additions |
| Hybrids | Union of parent files; merge conflicts reveal overlapping concerns |

## Composition guidelines (for merge-friendly templates)

To minimize cascade conflicts:

1. **Separate concerns into separate files** where possible (don't edit the same line in base and mixin).
2. **Use distinct cookiecutter keys** for mixin-specific options in `cookiecutter.json` — merging JSON may conflict on shared keys.
3. **Prefer additive directory structure** — new subdirs/files merge cleaner than editing shared `docker-compose.yml`.
4. **Document overlap zones** — e.g. both `traefik` and `dockhand` may touch compose; hybrids need a resolved canonical compose.

## `mix` vs persisted hybrid branch

| Approach | When |
|----------|------|
| `cc mix base mixin` | Experiment, one-off generation, conflict probe |
| Branch `{base}--{mixin}` | Reusable alias, registry entry, cascade target |

Persisted branches are required for `template create` with registry aliases.

## Post-generation hooks

Standard Cookiecutter hooks (`hooks/post_gen_project.py`) work per branch. When branches merge, hook files from both parents may coexist — ensure merged branch has coherent hook behavior.

## Generated project git init

Optional `--push-url` on `init`, `mix`, `template create`:
- `git init`, commit all, add remote, push to `main`
- Assumes exactly **one** new directory appears in output dir
