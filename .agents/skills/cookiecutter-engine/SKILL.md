---
name: cookiecutter-engine
description: Architecture and commands for the Git-Branch based Cookiecutter Engine (`cc`). Use when modifying the CLI, adding base branches, performing cascade merges, working on template branches, or resuming cc project work after time away.
---

# Cookiecutter Engine (cc)

You are operating inside `cc`, the core engine for branch-based Cookiecutter templating.

## Read first

Load [.agents/knowledge/INDEX.md](../../knowledge/INDEX.md) for the full knowledge base. Key files:

| Situation | Read |
|-----------|------|
| Resuming after a gap | [07-current-state.md](../../knowledge/07-current-state.md), [08-roadmap.md](../../knowledge/08-roadmap.md) |
| Branch naming / cascade | [03-branch-inheritance.md](../../knowledge/03-branch-inheritance.md) |
| CLI commands | [04-cli-and-just.md](../../knowledge/04-cli-and-just.md) |
| Cascade implementation | [05-cascade-internals.md](../../knowledge/05-cascade-internals.md) |

## Golden rules

1. **Never build hybrid templates in `cc`**. Hybrids (e.g. `traefik--dockhand`) belong in `cc-templates` fork.
2. Base branches (`traefik`, `dockhand`, `py3.12`) live in `cc`, directly off `main`.
3. After changing a base branch, run **`just cc cascade`** (in the repo where hybrids exist) to propagate downward.
4. Branch hierarchy uses **`--`** separator; cascade only merges **direct** children.

## Quick commands

```bash
uv sync
uv run pre-commit run --all-files
just cc cascade                              # merge current branch → children
just tc new secure-dockhand                  # generate from registry alias
uv run cc-cli mix py3.12 traefik -o /tmp/app # ad-hoc merge probe
```

## Code map

| File | Role |
|------|------|
| `cc/cli.py` | Typer CLI |
| `cc/cascade.py` | Recursive merge engine |
| `cc.just` / `tc.just` | Just wrappers |

## Planned (not implemented)

AI conflict resolution — see `GEMINI_INTEGRATION.md` and [08-roadmap.md](../../knowledge/08-roadmap.md).
