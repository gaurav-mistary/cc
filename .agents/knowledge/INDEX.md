# CC Knowledge Base — Index

Persistent context for AI agents working on the **Custom Cookiecutter (cc)** engine. Read this index first, then load topic files as needed.

## Start here

| File | When to read |
|------|--------------|
| [01-vision-and-problem.md](01-vision-and-problem.md) | Understanding *why* this project exists |
| [02-architecture.md](02-architecture.md) | Two-repo model, remotes, high-level data flow |
| [03-branch-inheritance.md](03-branch-inheritance.md) | Branch naming, tree rules, cascade semantics |
| [07-current-state.md](07-current-state.md) | What is implemented today vs planned |
| [08-roadmap.md](08-roadmap.md) | Known next steps and open design questions |
| [11-structure-and-changelog.md](11-structure-and-changelog.md) | What changed + final repo/image structure |

## Reference (load on demand)

| File | When to read |
|------|--------------|
| [04-cli-and-just.md](04-cli-and-just.md) | Commands, env vars, just wrappers |
| [05-cascade-internals.md](05-cascade-internals.md) | `cc/cascade.py` behavior, CI, logs |
| [06-template-anatomy.md](06-template-anatomy.md) | Cookiecutter layout expected on each branch |
| [09-cc-templates-catalog.md](09-cc-templates-catalog.md) | Self-hosted service template library repo |
| [10-docker-server-runtime.md](10-docker-server-runtime.md) | Pull image on server, generate from branch |

## Human docs (repo root)

- `AGENTS.md` — short architecture summary (always applied in Cursor)
- `README.md` — user-facing usage
- `GEMINI_INTEGRATION.md` — design doc for AI conflict resolution (not implemented)

## Skill entry point

Cursor skill: `.agents/skills/cookiecutter-engine/SKILL.md`
