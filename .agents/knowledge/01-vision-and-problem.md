# Vision and Problem

## The problem: Cookiecutter drift

Standard [Cookiecutter](https://github.com/cookiecutter/cookiecutter) generates a project snapshot from a template directory. After generation:

- The output is **frozen** — upstream template fixes never reach existing projects.
- Maintaining **variants** (base webserver, webserver + TLS, webserver + TLS + admin UI) means duplicating folders or copy-pasting shared files across templates.

## The user's goal

Use the **cookiecutter Python package** as the generator, but store templates as **Git branches** in a repository where:

1. **Branches are hierarchical** — a parent branch holds shared base content; child branches add layers.
2. **Parent updates propagate downward** — when `traefik` changes, those changes merge into `traefik--secure`, `traefik--dockhand`, etc.
3. **Git is the inheritance mechanism** — not nested folders in one checkout, but real branches with merge-based composition.

Think of it as **object-oriented templates**: base class branches, mixin branches, composed hybrid branches — all versioned in Git.

## What success looks like

- Edit a base technology once (e.g. bump Traefik version on `traefik`).
- Run cascade → all hybrid branches pick up the change automatically (or conflict visibly).
- Users scaffold projects with friendly aliases (`just tc secure-dockhand`) that resolve to pre-merged branches.
- Optional: on-demand mixing (`cc mix`) for ad-hoc combinations without persisting a branch.

## Non-goals (for now)

- Automatically updating **already-generated** user projects (that is a separate "template sync" problem).
- Replacing Cookiecutter's Jinja templating — branches hold Cookiecutter templates; Git handles composition.
