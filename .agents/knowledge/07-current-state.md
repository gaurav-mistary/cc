# Current State (as of Aug 2026)

Snapshot for agents resuming work after a gap.

## Implemented and working

| Feature | Status | Location |
|---------|--------|----------|
| Typer CLI | ✅ | `cc/cli.py` |
| Branch cascade merge | ✅ | `cc/cascade.py` |
| Recursive child discovery (`--` naming) | ✅ | `get_direct_children` |
| Cascade JSON reports | ✅ | `cascade_log_*.json` |
| Registry alias resolution (local + URL) | ✅ | `template create` |
| Cookiecutter generation by branch | ✅ | `init`, `template create` |
| Ad-hoc branch mixing | ✅ | `mix` |
| Optional git init + push after generate | ✅ | `push_git()` |
| Just wrappers (`cc`, `tc`) | ✅ | `justfile`, `cc.just`, `tc.just` |
| Docker packaging | ✅ | `Dockerfile`, `.dockerignore` |
| GHCR publish CI | ✅ | `.github/workflows/docker-publish.yml` → `ghcr.io/gaurav-mistary/cc` |
| CI auto-cascade on merged PR | ✅ | `.github/workflows/cascade.yml` |
| Pre-commit (black, isort, ty) | ✅ | `.pre-commit-config.yaml` |

## Base branches present (local/origin)

- `traefik`, `dockhand`, `py3.12`
- Hybrids on upstream cc: `traefik--secure`, `traefik--dockhand`

## Templates fork extras

- `traefik--secure--dockhand` on `templates` remote (not on `origin/cc`)

## Documented but NOT implemented

| Item | Doc | Notes |
|------|-----|-------|
| Gemini AI conflict resolver | `GEMINI_INTEGRATION.md` | No `cc/ai_resolver.py`; no code in cascade |
| `google-generativeai` dep | GEMINI doc | Not in `pyproject.toml` |

## Repo hygiene / loose ends

- Untracked `cascade_log_*.json` files in repo root (should probably be gitignored)
- `plane-docker-compose.yml` — untracked, purpose unclear (likely scratch/test)
- `rename_branches.sh` — one-time migration script, kept for reference
- `cc.just` has `create` recipe pointing to `cc.cli create` — **no `create` command exists** in CLI (stale recipe; use `template create` or `init`)
- `.env.example` only documents `FACTORY_URL`; other env vars undocumented there

## Last known successful cascade

From `cascade_log_20260804_154616.json`: cascade from `main` merged successfully into all five child branches with zero conflicts.

## Test coverage

No automated tests in repo. Validation is manual: run cascade, run cookiecutter generation.
