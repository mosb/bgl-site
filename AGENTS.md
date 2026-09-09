# Agent Guidelines for al-folio (v1.x)

`al-folio` is the **starter repo** for the pluginized v1 architecture.

## Read This First

- Start with `.github/copilot-instructions.md` for architecture and ownership boundaries; its CI expectations describe upstream, not this fork.
- Use `docs/BOUNDARIES.md` as the source of truth for starter-vs-plugin ownership.
- Use `.agents/skills/al-folio-bootstrap/SKILL.md` for new-site setup tasks.
- Use `.agents/skills/al-folio-v1-migration/SKILL.md` for customized fork migrations.
- `.codex/skills` and `.claude/skills` are symlinks to `.agents/skills` for agent-specific discovery.

## What This Repo Owns

- Starter wiring (`Gemfile`, `_config.yml`)
- Starter content and documentation
- Cross-plugin integration tests
- Visual regression tests

Runtime/component logic belongs in owning plugin repos (`al_folio_core`, `al_folio_distill`, `al_search`, `al_icons`, `al_cookie`, and other `al-*` gems).
Long-form documentation lives in `docs/`; keep this root file as the short discovery entry point for coding agents.

## Validated Local Command Set

Run from repo root:

```bash
npm ci
npm run lint:prettier
npm run lint:style-contract
bundle exec jekyll serve                        # dev server → http://localhost:4000/~mosb/bgl/
JEKYLL_ENV=production bundle exec jekyll build  # production build; pass no --baseurl
bash test/integration_plugin_toggles.sh
bash test/integration_bootstrap_compat.sh
bash test/integration_css_minify.sh
bash test/integration_upgrade_cli.sh
npx playwright install chromium webkit
npm run test:visual
bundle exec al-folio upgrade audit
bundle exec al-folio upgrade overrides audit
bundle exec al-folio upgrade report
./deploy.sh                                     # build + rsync to the Oxford web space
curl -fsS https://www.robots.ox.ac.uk/~mosb/bgl/ >/dev/null
```

Notes for this fork:

- **No CI.** There are no `.github/workflows`; a push to `origin` publishes nothing and runs no checks. Anything above that matters must be run by hand, and `./deploy.sh` is the only thing that changes the live site.
- **`baseurl` is `/~mosb/bgl`**, set in `_config.yml`. Never override it on the command line; upstream's `--baseurl /al-folio` breaks every asset link.
- **`lint:style-contract` fails by design**, because this site deliberately owns `_includes` and `_sass` (see `.al-folio-overrides.yml`). Read the report; do not "fix" it by deleting the overrides.
- **Docker does not work here.** `bin/` was deleted in `78cae42`, so both the `Dockerfile` build and the compose `command` depend on a missing `bin/entry_point.sh`. See `CLAUDE.md`.
- **Two integration scripts are dead** and are left out of the list above. `test/integration_comments.sh` and `test/integration_distill.sh` assert on the al-folio demo posts (`blog/2022/giscus-comments`, `blog/2021/distill`), which went with the demo collections in `78cae42`; `_posts` is empty, so they fail on a missing page rather than on anything real. Delete them or point them at a fixture before trusting either.

The command set above was last run in full on 9 September 2026: everything listed passes, `lint:style-contract` excepted as noted.

## Agent Routing Rules

- If change is starter wiring/docs/integration/visual testing: edit here.
- If change is runtime feature behavior: route to owning plugin repo.
- Do not add starter-local npm build scripts for theme/runtime assets.
- Keep docs aligned with pluginized v1 ownership.
- If you create or keep local overrides of plugin-owned files, run `bundle exec al-folio upgrade overrides audit` and commit `.al-folio-overrides.yml` after review.
