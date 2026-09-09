# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

@AGENTS.md

The import above (`AGENTS.md`, which itself defers to `.github/copilot-instructions.md` and `docs/BOUNDARIES.md`) is the canonical short entry point: ownership boundaries, the validated command set, and PR-routing rules. Keep `AGENTS.md` short and ecosystem-neutral — put Claude-specific or longer-form guidance here instead. Everything below is the cross-repo "big picture" that those files assume but don't spell out.

## What this repo is

`al-folio` v1.x is a **thin Jekyll starter**, not a theme. It owns only: starter wiring (`Gemfile`, `_config.yml`, `_data/featured_plugins.yml`), example content (`_pages`, `_posts`, `_projects`, `_news`, `_teachings`, `_books`, `_bibliography`), docs (`docs/`), cross-gem integration tests (`test/integration_*.sh`), and visual/parity tests (`test/visual/`). **All runtime, layouts, includes, Sass, tags, filters, and feature JS live in versioned gems**, published independently on RubyGems. `docs/BOUNDARIES.md` is the authoritative area→gem ownership table.

The biggest recurring mistake is editing runtime here. If a change is layout/include/tag/filter/feature-behavior, it belongs in the owning gem (see routing below), not in this repo.

## The plugin ecosystem (read this before routing any change)

The `al-*` / `al_folio_*` gems are developed as **sibling repos on disk** at `~/Documents/dev/al-org/<repo>` (repo dir uses hyphens, e.g. `al-folio-core`; gem/plugin id uses underscores, e.g. `al_folio_core`). To test a gem fix against this site, point the `Gemfile` at it: `gem "al_folio_core", path: "../al-folio-core"` (or `git:`/`branch:`), then `bundle install`.

**`al_folio_core` is the hub.** `_config.yml` sets `theme: al_folio_core`; the gem ships every base `_layouts/*.liquid` and `_includes/*.liquid`, the base theme JS/CSS, and the `details`/`file_exists` tags + `hideCustomBibtex`/`remove_accents` filters. Crucially, its `_includes/plugins/*.liquid` are **thin wrappers that call custom Liquid tags defined by sibling gems**. So a feature renders only when _both_ (a) its gem is present in the plugin list, and (b) the relevant flag is on. The wrapper→tag→gem delegation map:

| Wrapper / call site       | Tag                                                 | Gem                                                                            |
| ------------------------- | --------------------------------------------------- | ------------------------------------------------------------------------------ |
| search assets             | `al_search_assets`                                  | `al_search` (Cmd-K ninja-keys palette; index built at build time from content) |
| comments                  | `al_comments`                                       | `al_comments` (Giscus + Disqus, front-matter gated)                            |
| cookie banner             | `al_cookie_styles` / `al_cookie_scripts`            | `al_cookie` (consent-mode gating of analytics)                                 |
| icon `<link>`s            | `al_icons_styles`                                   | `al_icons` (FontAwesome/Academicons/Scholar Icons from CDN)                    |
| analytics                 | `al_analytics_scripts`                              | `al_analytics` (GA/Cronitor/Pirsch/OpenPanel)                                  |
| math                      | `al_math_styles` / `al_math_scripts`                | `al_math` (MathJax, pseudocode.js, TikZJax)                                    |
| charts                    | `al_charts_scripts`                                 | `al_charts` (Mermaid/Chart.js/ECharts/Plotly/Vega/Leaflet/diff2html)           |
| image tools               | `al_img_tools_styles` / `al_img_tools_scripts`      | `al_img_tools` (zoom, lightbox, sliders, galleries)                            |
| newsletter                | `al_newsletter_form` / `al_newsletter_scripts`      | `al_newsletter` (Loops.so signup)                                              |
| `layout: cv`              | `al_folio_cv_render`                                | `al_folio_cv` (RenderCV YAML + JSONResume)                                     |
| `layout: distill`         | `al_folio_distill_render`                           | `al_folio_distill` (vendored, hash-pinned distillpub runtime)                  |
| citation badges           | `google_scholar_citations` / `inspirehep_citations` | `al_citations`                                                                 |
| external posts            | (generator, no tag)                                 | `al_ext_posts` (RSS/URL ingestion → synthetic posts)                           |
| legacy Bootstrap behavior | (opt-in assets)                                     | `al_folio_bootstrap_compat`                                                    |
| upgrade/audit CLI         | `bundle exec al-folio …`                            | `al_folio_upgrade`                                                             |

Architectural facts that span repos:

- **Feature gating is two-layered.** Site-wide config flags (`search_enabled`, `enable_math`, `enable_cookie_consent`, `enable_darkmode`, `al_folio.features.cv.enabled`, `al_folio.features.distill.enabled`) _and_ per-page front matter (`images:`, `tikzjax`, `chart.*`, `mermaid.*`, `giscus_comments`, `layout: distill|cv`). A tag emits an empty string when its gem/flag/config is absent — features fail silently, not loudly.
- **Most feature gems are `AssetsGenerator`s** that inject their JS/CSS as Jekyll static files at build time _only when enabled_. These assets are not committed into the site, and several use pinned-CDN URLs + SRI hashes read from `_config.yml`'s `third_party_libraries:` block.
- **Two parallel lists must stay in sync:** `Gemfile` (pinned versions, e.g. `al_folio_core '= 1.0.9'`) and `_config.yml`'s `plugins:` list. Adding/removing a plugin means editing both.
- **The v1 config contract** (`al_folio.api_version: 1`, `style_engine: tailwind`, `tailwind.{version,css_entry,preflight}`, `distill.{engine,source}`) is enforced twice: as build-time warnings/violations by `al_folio_core`'s `:after_init` hook, and as **blocking** findings by `al-folio upgrade audit`. Don't remove these keys.
- **Local overrides are allowed but tracked.** A site may shadow a gem-owned `_layouts/_includes/_sass` file locally. When it does, `al-folio upgrade overrides audit` records owner gem + version + upstream/local SHA256 in `.al-folio-overrides.yml`; that file must be committed so future `bundle update`s can flag upstream drift. Shared fixes should be ported to the owning gem instead.
- **Bootstrap compat is opt-in and time-boxed.** `al_folio.compat.bootstrap.enabled: true` (default false) activates `al_folio_bootstrap_compat`. Supported through v1.2, deprecated v1.3, removed in v2.0 — migrate content off `data-toggle`/Bootstrap classes before then.

## Daily dev loop (not in the AGENTS.md command set)

```bash
bundle install                                # ruby gems
bundle exec jekyll serve                      # dev server → http://localhost:4000/~mosb/bgl/ (NOTE baseurl)
JEKYLL_ENV=production bundle exec jekyll build # production build to _site/ (no --baseurl flag)
bash test/integration_plugin_toggles.sh      # run ONE integration test (any of test/integration_*.sh)
npm run test:visual:update                    # refresh playwright snapshots after intentional UI change
bundle exec al-folio upgrade apply --safe     # deterministic codemods (font-weight-* → font-*, remote→local URLs)
bundle exec al-folio upgrade overrides diff <path>    # then `overrides accept <path>` to acknowledge an override
```

`requirements.txt` holds the optional Python toolchain (`nbconvert` for `jekyll-jupyter-notebook`, `pyyaml`, `scholarly`); install it yourself, as this fork carries no `bin/` directory and so none of upstream's `bin/*` helpers. Responsive-image generation (`imagemagick.enabled: true`) needs ImageMagick `convert` on PATH.

## Building and deploying

This site is published to Oxford web space, not to GitHub Pages, and **nothing deploys automatically**. There are no `.github/workflows` here, so a push to `origin` stores the commits and changes the live site not at all. Publishing is `./deploy.sh`, which:

- builds with `JEKYLL_ENV=production bundle exec jekyll build`. Pass no `--baseurl`: `_config.yml` already sets `url: https://www.robots.ox.ac.uk` and `baseurl: /~mosb/bgl`, and overriding either breaks every asset link.
- rsyncs `_site/` to `mosb@login.robots.ox.ac.uk:~/WWW/bgl` with `-rtvz --delete --chmod=D755,F644`, through Homebrew's `/opt/homebrew/bin/rsync` (the system rsync on macOS is too old for `--iconv`).
- shows a dry run and waits for a `y` before writing anything. That prompt needs a TTY, so an agent running non-interactively should invoke the same rsync twice instead: once with `--dry-run`, to check the file list and any deletions, then for real.

Confirm the result against the live URL rather than `_site/`, e.g. `curl -fsS https://www.robots.ox.ac.uk/~mosb/bgl/people/`. Note that `deploy.sh` runs no purgecss step, whatever `purgecss.config.js` and `docs/INSTALL.md` still imply.

## Docker (upstream leftover, does not work here)

`Dockerfile`, `docker-compose.yml` and `docker-compose-slim.yml` are inherited from upstream al-folio and are **broken in this fork**. `bin/` was deleted in `78cae42` (19 June 2026) with the rest of the al-folio demo material, and both Docker paths depend on it: the `Dockerfile` does `COPY bin/entry_point.sh`, so `build: .` fails outright, and `docker-compose.yml`'s `command: /srv/jekyll/bin/entry_point.sh` cannot resolve even against the prebuilt `amirpourmand/al-folio` image, because the `.:/srv/jekyll` bind mount shadows the image's own `bin/` with the host tree, which has none.

Serve locally with `bundle exec jekyll serve` instead. Either restore `bin/entry_point.sh` or delete these three files; leaving them in place keeps sending agents down a path that cannot work.

## Checks and the style contract

There is no CI in this fork. Upstream al-folio gates every push with `unit-tests.yml`, `visual-regression.yml`, `upgrade-check.yml` and `prettier.yml`; none of those workflows exist here, so **whatever you do not run by hand does not get run**. Before deploying: `npm run lint:prettier`, `npm run lint:style-contract`, the `test/integration_*.sh` scripts, and `npm run test:visual` for a UI change.

`npm run lint:style-contract` (`test/style_contract.js`) is the check that enforces the thin-starter boundary: the starter must **not** define `build:css`/`build:tailwind` npm scripts, must **not** own `_includes`/`_layouts`/`_sass`/`_scripts`/`assets/tailwind`/`tailwind.config.js`/icon-font artifacts, must keep `theme: al_folio_core` and the required plugins in `_config.yml`, and must keep the `third_party_libraries` SRI pins and `al_math` Gemfile pin. Note that this repo does own `_includes` and `_sass` locally (see `.al-folio-overrides.yml`), so read what the script actually reports rather than assuming a clean run. Prettier uses `@shopify/prettier-plugin-liquid` with `printWidth: 150`.
