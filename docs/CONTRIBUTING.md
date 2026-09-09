# Contributing

This repository is the Bayesian Governance Lab website, not the al-folio theme.
Most contributions are content: a member profile, a publication, a news item.

## Content changes

Open a pull request against `main`.
Maike reviews, merges, and deploys; nothing reaches the live site until `./deploy.sh` runs.

- **Your own profile.** Edit `_data/members.yml` and add a photo to `assets/img/`.
  See [QUICKSTART.md](QUICKSTART.md).
- **Publications.** Add to `_bibliography/papers.bib`, following the style of the entries already there: initialised given names, an abstract, and `arxiv`, `doi` or `url` links where they exist.
- **News.** A short markdown file in `_news/`.
- **Pages.** `_pages/`, for the about and join pages.

Prose is British English.
Member blurbs are one to three sentences, third person, and avoid pronouns unless the member asks otherwise, so that the page reads consistently.

## Checks before deploying

There is no CI in this repository, so anything not run by hand is not run at all.

```bash
npm ci
npm run lint:prettier
npm run lint:style-contract
JEKYLL_ENV=production bundle exec jekyll build
bash test/integration_plugin_toggles.sh
bash test/integration_bootstrap_compat.sh
bash test/integration_css_minify.sh
bash test/integration_upgrade_cli.sh
npx playwright install chromium webkit
npm run test:visual
```

Two expected failures, neither of which should be "fixed":

- `lint:style-contract` reports that the starter must not own `_includes` or `_sass`.
  It owns both deliberately.
- `lint:prettier` fails on `_config.yml`, whose comments are hand-aligned.

## Theme changes

If the problem is in a layout, include, tag, filter or feature behaviour, it belongs to a gem, not here.
`al_folio_core` is the hub; the delegation table in [`CLAUDE.md`](../CLAUDE.md) says which gem owns which feature, and [BOUNDARIES.md](BOUNDARIES.md) is the full ownership contract.

To test a gem fix against this site, point the `Gemfile` at a local checkout and `bundle install`:

```ruby
gem "al_folio_core", path: "../al-folio-core"
```

A site-local override is usually enough for a one-off change: add the gem-owned path to this repository, then run `bundle exec al-folio upgrade overrides audit` and commit `.al-folio-overrides.yml` so later gem updates flag the drift.
Contribute the fix upstream when it is not specific to this site.

## Agent entry points

The repository carries instructions for coding agents:

- `CLAUDE.md`, which imports `AGENTS.md`; between them they hold the architecture, the command set, and the ways this fork departs from upstream.
- `.agents/skills/` for repeatable workflows, with `.codex/skills/` and `.claude/skills/` as symlinks to it.
- `.github/copilot-instructions.md` and `.github/instructions/` for Copilot, per file type.
- `.github/agents/customize.agent.md` and `.github/agents/docs.agent.md`.

Agent output needs the same review as anyone else's: build the site, look at the pages you changed, and check YAML and BibTeX syntax before committing.
Upstream's agent documentation assumes a Copilot environment workflow that does not exist here.

## Licence

The theme is al-folio, MIT licensed.
Site content is the lab's.
