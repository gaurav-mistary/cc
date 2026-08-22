# Branch Inheritance Model

## Naming convention

Branches use **`--` (double hyphen)** as the hierarchy separator.

| Pattern | Meaning | Example |
|---------|---------|---------|
| `main` | CLI engine only (on `cc` repo) | — |
| `{name}` | Base template (direct child of `main`) | `traefik`, `dockhand`, `py3.12` |
| `{parent}--{child}` | One mixin/layer added | `traefik--secure` |
| `{a}--{b}--{c}` | Composed stack | `traefik--secure--dockhand` |

**Historical note:** Branches used to use `/` paths (e.g. `traefik/scratch`). `rename_branches.sh` migrated `/` → `--` and stripped `/scratch`.

**Python version bases:** Named `py3.12`, `py3.11`, etc. CLI can prefix: `--pyv 3.12` + template `traefik` → branch `py3.12--traefik`.

## Tree rules (implemented in `get_direct_children`)

### From `main`

Direct children = **all local branches** where:
- name ≠ `main`
- name contains **no** `--`

So from `main`, children are: `traefik`, `dockhand`, `py3.12` — not `traefik--secure`.

### From any other branch `{name}`

Direct children = branches where:
- name starts with `{name}--`
- exactly **one more** `--` segment than `{name}`

Examples from `traefik` (depth 0 → target depth 1):
- ✅ `traefik--secure`, `traefik--dockhand`
- ❌ `traefik--secure--dockhand` (depth 2 — grandchild, not direct child)

Examples from `traefik--secure` (depth 1 → target depth 2):
- ✅ `traefik--secure--dockhand`

## Cascade semantics

**Command:** `just cc cascade` (from current branch)

**Behavior:**
1. Requires clean working tree.
2. Finds direct children of **current** branch.
3. For each child: checkout → `git merge {parent}` → push to `origin`.
4. On success, recurses into that child.
5. On conflict: abort merge, skip child **and all descendants**, continue siblings.
6. Returns to original branch; writes `cascade_log_YYYYMMDD_HHMMSS.json`.

**Important:** Cascade merges **parent into child** (child receives parent's updates). Child-specific files should survive if Git can auto-merge.

**Conflict recovery:** Manually resolve on the conflicted branch, commit, then re-run cascade **from that branch** to continue downward.

## Observed branch tree (Aug 2026)

### On `origin` / local `cc`:

```
main
├── traefik
│   ├── traefik--secure
│   └── traefik--dockhand
├── dockhand
└── py3.12
```

### On `templates` remote (cc-templates fork) — additionally:

```
traefik--secure--dockhand   (hybrid not in upstream cc)
```

## Creating new branches

### Base (in `cc`)

```bash
git checkout main
git checkout -b my-base
# add cookiecutter template at branch root
git commit && git push -u origin my-base
```

### Hybrid (in `cc-templates` fork)

```bash
git checkout -b traefik--myfeature origin/traefik
git merge origin/my-mixin --no-edit   # or merge files manually
# resolve conflicts, ensure valid cookiecutter layout
git push -u origin traefik--myfeature
```

Or use `cc mix traefik my-mixin` to probe merge viability before creating a branch.

## Design tension: `py3.12` as parallel base

`py3.12` sits alongside `traefik` as a main child — it is a **language runtime base**, not a web stack. Compositions like `py3.12--traefik` are naming-convention hybrids, not automatic Git children unless explicitly branched.
