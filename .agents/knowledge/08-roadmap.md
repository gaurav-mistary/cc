# Roadmap and Open Questions

Topics to discuss **one by one** with the user. Ordered roughly by dependency.

## Near-term engineering

1. **AI merge resolver** — Implement `GEMINI_INTEGRATION.md` in `cc/ai_resolver.py`; hook into cascade conflict path; rate-limit for free tier.
2. **Cascade log hygiene** — Gitignore `cascade_log_*.json` or write to configurable output dir.
3. **Fix stale `cc.just create`** — Remove or alias to `template create` / `init`.
4. **Complete `.env.example`** — Document `TEMPLATES_REPO_URL`, `CC_REGISTRY`, `GEMINI_API_KEY`.
5. **Tests** — Unit tests for `get_direct_children`; integration test with temp git repo for cascade.
6. **Remote configurability** — Cascade pushes hardcode `origin`; support `templates` remote or env override.

## cc-templates catalog

7. **Service branches** — Add templates: `immich`, `audiobookshelf`, `vaultwarden`, `backups`, …
8. **registry.json** — Friendly aliases for every service and common hybrids (`traefik--secure--immich`).
9. **Sync from cc** — Keep shared bases (`traefik`, `py3.12`) in sync; cascade in `cc-templates`.
10. **Merge-friendly template design** — Audit compose overlap when stacking services.

## Docker publish (server pull)

11. **GHCR publish workflow** — ✅ `.github/workflows/docker-publish.yml` pushes `ghcr.io/gaurav-mistary/cc`
12. **Server docs** — ✅ README Docker section; make package Public after first push
13. **Verify cookiecutter over HTTPS** — smoke-test `template create` against public `cc-templates`

## CI / workflow

14. **Cascade trigger semantics** — Should CI cascade from merged **head** branch instead of PR base when updating a base branch directly?
15. **Cascade across repos** — Today: sync cc → cc-templates manually, then cascade in fork. Automate sync?
16. **Conflict notification** — Open GitHub issue or PR when cascade fails in CI?

## Product / UX

13. **Updating generated projects** — Out of scope today; possible future: `cc upgrade` diffing template branch vs project.
14. **Interactive cookiecutter** — Extra args passthrough exists; document common patterns in registry metadata?
15. **Version pinning** — Tag template branches? Cookiecutter `--checkout` supports tags.

## Architecture questions (unsettled)

- Should hybrids like `traefik--secure--dockhand` always be **merge-derived**, or sometimes **generated-only** via `mix`?
- Is `main` the right cascade root when bases (`traefik`) change on their own branches without merging to main first?
- Single monorepo vs strict two-repo split long term?

## Discussion tracker

Use this section to append decisions as they are made in conversation:

| Date | Topic | Decision |
|------|-------|----------|
| — | — | (empty — fill in as we go) |
