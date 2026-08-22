# Cascade Internals

Source: `cc/cascade.py`

## Public API

```python
run_cascade_merge()  # called by cc-cli cascade
```

## Algorithm

```
run_cascade_merge():
  assert clean working tree
  base = current branch
  cascade_merge_recursive(repo, base, conflicts=[], successes=[])
  checkout base
  write cascade_log_*.json
```

```
cascade_merge_recursive(repo, parent, ...):
  children = get_direct_children(repo, parent)
  for child in children:
    try:
      checkout child
      merge parent into child  (message: chore(auto): merge 'parent' into 'child')
      push origin child
      cascade_merge_recursive(repo, child, ...)
    except GitCommandError:
      merge --abort
      append child to conflicts
      # do NOT recurse into child
```

## Child discovery (`get_direct_children`)

Uses **local** `repo.heads` only — remote-only branches are invisible until tracked locally.

CI workaround (`.github/workflows/cascade.yml`):

```bash
for remote in $(git branch -r | grep -v '\->' | grep origin/); do
  git branch --track "${remote#origin/}" "$remote" || true
done
```

## Merge report JSON

Example from successful run (`cascade_log_20260804_154616.json`):

```json
{
  "timestamp": "2026-08-04T15:46:16.764669+00:00",
  "base_branch": "main",
  "successful_merges": ["dockhand", "py3.12", "traefik", "traefik--dockhand", "traefik--secure"],
  "failed_merges": []
}
```

Log files are written to **cwd** — several untracked `cascade_log_*.json` exist in repo root from past runs. Consider gitignoring or outputting to `.cache/`.

## CI auto-cascade

Trigger: PR merged to base branch (unless title/body contains `[skip cascade]`).

Steps: checkout base ref → track all remote branches → `uv sync` → `just cc cascade` → upload log artifact.

**Caveat:** CI runs cascade from the **PR base branch** (e.g. `main`), not from the branch that was merged. This matches "propagate main's view" when bases were updated on main — verify this matches intended workflow when bases live on separate branches.

## Known limitations

1. **Push target hardcoded** — always `origin`, not configurable remote name.
2. **No dry-run** — merges and pushes immediately.
3. **Conflict = skip subtree** — no partial progress within a conflicted branch.
4. **Local heads only** — must fetch + track branches before cascade.
5. **No AI resolver yet** — `GEMINI_INTEGRATION.md` describes planned auto-resolution; not in code.

## Planned enhancement (documented, not built)

On `GitCommandError`: detect conflicted files → Gemini API → write resolved content → commit → continue cascade. See `GEMINI_INTEGRATION.md`.
