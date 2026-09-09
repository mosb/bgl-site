# Installing and Deploying

How to build this site locally and how it reaches `https://www.robots.ox.ac.uk/~mosb/bgl/`.

## Local setup

You need [Ruby](https://www.ruby-lang.org/en/downloads/) and [Bundler](https://bundler.io/); a version manager such as `rbenv` or `chruby` keeps this off the system Ruby, which on macOS is too old.

```bash
bundle install
bundle exec jekyll serve
```

Then open <http://localhost:4000/~mosb/bgl/>.
Note the path: `baseurl` is `/~mosb/bgl`, so the bare `localhost:4000` root gives a 404.
That is correct behaviour, not a broken build.

Two optional extras:

- **Python toolchain.** `requirements.txt` lists `nbconvert` (for `jekyll-jupyter-notebook`), `pyyaml`, and `scholarly`.
  Install it yourself; there is no `bin/setup-python-deps` here.
  If `jekyll-jupyter-notebook` is enabled and `jupyter-nbconvert` is missing, the build continues and skips notebook rendering with a warning.
- **ImageMagick.** Responsive image generation (`imagemagick.enabled: true` in `_config.yml`) needs `convert` on `PATH`.

There is no Docker or devcontainer path.
Both were removed, because they depended on `bin/entry_point.sh`, which went with the al-folio demo material.

## Production build

```bash
JEKYLL_ENV=production bundle exec jekyll build
```

Output lands in `_site/`.

Pass no `--baseurl`.
`_config.yml` already sets `url: https://www.robots.ox.ac.uk` and `baseurl: /~mosb/bgl`; overriding either on the command line breaks every asset link on the built pages.
Upstream documentation that tells you to build with `--baseurl /al-folio` is describing the al-folio demo site, not this one.

## Deploying

`./deploy.sh` does the whole job: production build, then rsync of `_site/` into the Oxford web space.

```bash
./deploy.sh
```

What it does, in order:

1. Builds with `JEKYLL_ENV=production bundle exec jekyll build`.
2. Runs `rsync --dry-run` against `mosb@login.robots.ox.ac.uk:~/WWW/bgl` and prints what would change.
3. Waits for a `y` at the terminal, and does nothing at all if it does not get one.
4. Repeats the rsync for real, with `-rtvz --delete --chmod=D755,F644`.

Some details that matter:

- It uses Homebrew's `/opt/homebrew/bin/rsync`, since the system rsync on macOS is too old for `--iconv`.
- `--delete` means the remote mirrors `_site/` exactly.
  Read the dry run before confirming.
- SSH access to `login.robots.ox.ac.uk` is assumed to be set up already, with a key or an agent.
- The confirmation prompt needs a terminal.
  Running the script non-interactively fails at the prompt rather than deploying, which is deliberate.
  An agent should run the same rsync twice instead, once with `--dry-run` to review the file list, then for real.

Nothing else publishes.
There are no GitHub Actions workflows in this repository, so pushing to `origin` stores the commits and leaves the live site untouched.

## After deploying

Check the live URL, not `_site/`:

```bash
curl -fsS https://www.robots.ox.ac.uk/~mosb/bgl/people/ >/dev/null
```

If a page looks stale or unstyled in a browser after a successful deploy, suspect the browser before the build.
Stylesheet links are hash-busted (`main.css?v=...`), but not every browser honours a changed query string; a hard reload settles it.

## Maintaining dependencies

Ruby packages are managed with Bundler and pinned in `Gemfile.lock`.

```bash
bundle install                 # install what the lockfile says
bundle update <gem-name>       # update one gem deliberately
bundle update                  # refresh everything, then commit the lockfile
```

After any update, build locally and look at the site before deploying.
There is no CI to catch a regression for you.

Two lists must stay in step: the `Gemfile` (pinned plugin versions) and the `plugins:` list in `_config.yml`.
Adding or removing a plugin means editing both.

## Upgrading al-folio

The theme ships an upgrade CLI and versioned migration manifests, which is the supported way through minor versions.

```bash
bundle update
bundle exec al-folio upgrade audit
bundle exec al-folio upgrade apply --safe
bundle exec al-folio upgrade report
```

The report is written to `al-folio-upgrade-report.md`, and classifies findings as **blocking** (resolve before calling the upgrade done) or **non-blocking** (deprecated patterns to migrate over time).

Legacy Bootstrap content is handled by `al_folio.compat.bootstrap.enabled: true` in `_config.yml`, with `al_folio_bootstrap_compat` in the plugin list.
Compatibility is supported through v1.2, deprecated in v1.3, and removed in v2.0, so content should be migrated off `data-toggle` and Bootstrap classes before then.

## Tracking local overrides

Two kinds of local file live in `_includes/` and `_sass/` here, and the difference matters.

**Shadowed gem files**, recorded in `.al-folio-overrides.yml`: `_includes/footer.liquid`, `_includes/header.liquid`, and `_sass/_themes.scss`.
Each has an upstream original owned by `al_folio_core`.
Git will not raise a conflict when the gem updates the file your copy shadows, so the upgrade CLI keeps that review signal instead:

```bash
bundle exec al-folio upgrade overrides audit
bundle exec al-folio upgrade overrides diff _includes/header.liquid
bundle exec al-folio upgrade overrides accept _includes/header.liquid
```

**Site-original files**, which shadow nothing and need no tracking: `_includes/members_grid.liquid`, `_includes/people_list.liquid`, `_includes/bgl_affiliations.liquid`, and `_sass/_bgl_overrides.scss`.
The people page is rendered by the first two of these.

`.al-folio-overrides.yml` records the owning gem, its version, and the upstream and local checksums for each reviewed override.
Keep it committed, so that a later `bundle update` can flag upstream drift.

One consequence: `npm run lint:style-contract` fails here by design, reporting that the starter must not own `_includes` or `_sass`.
That is the overrides showing up, not a fault to fix.

For which repository owns what, see [BOUNDARIES.md](BOUNDARIES.md).
