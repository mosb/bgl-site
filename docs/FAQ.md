# Frequently Asked Questions

Questions about this site come first; questions about the al-folio theme underneath it come after.
For symptoms rather than questions, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## About this site

### I merged a change. Why is the live site the same?

Because merging does not deploy.
This site is not on GitHub Pages and has no Actions workflows; `./deploy.sh` builds and rsyncs to the Oxford web space, and only Maike runs it.
Your change goes live at the next deploy.

### How do I get on the people page?

Edit `_data/members.yml`, add a square photo to `assets/img/`, and open a pull request.
[QUICKSTART.md](QUICKSTART.md) has the detail, including what makes a good blurb.

### Do I have to supply a photo?

No.
Leave `image:` out and the card shows a tile with your initials, which several members use.

### Can I preview locally without Ruby?

Not any more.
The Docker and devcontainer paths were removed, because they depended on scripts that no longer exist in this repository.
`bundle install && bundle exec jekyll serve` is the only local preview, and it is not needed for a content change.

### Why does `localhost:4000` give a 404?

`baseurl` is `/~mosb/bgl`, so the site is served at <http://localhost:4000/~mosb/bgl/>.
The bare root is empty by design.

### Why does `npm run lint:style-contract` fail on a clean checkout?

Because this site owns `_includes` and `_sass` locally, which the upstream starter contract forbids.
That is a deliberate customisation, recorded in `.al-folio-overrides.yml`.
Do not "fix" it by deleting the local files.

### Where do blog posts go?

Nowhere: there is no blog.
`_posts/` is empty, and news items live in `_news/` as short markdown files shown on the front page.

## About the theme

### Do I need to fork a gem to change a layout or include?

No.
Gem-owned layouts and includes provide the default runtime, and a site can shadow any of them by adding the same path locally.
Fork or pin a gem only when the behaviour should change for every site using that plugin.

After a dependency update, run `bundle exec al-folio upgrade overrides audit` to catch overrides whose upstream file has moved on, and keep `.al-folio-overrides.yml` committed.

### How do I know when a local override is stale?

```bash
bundle exec al-folio upgrade overrides audit
bundle exec al-folio upgrade overrides diff _includes/header.liquid
bundle exec al-folio upgrade overrides accept _includes/header.liquid
```

The audit compares each local override against the file shipped by the installed gem, using the upstream checksum you last acknowledged.

### How do I upgrade the theme?

```bash
bundle update
bundle exec al-folio upgrade audit
bundle exec al-folio upgrade overrides audit
bundle exec al-folio upgrade apply --safe
bundle exec al-folio upgrade report
```

Resolve every **blocking** finding in `al-folio-upgrade-report.md`; non-blocking ones are deprecated patterns to migrate over time.
Build and look at the site before deploying, since nothing else will check it.

### Why is there no `npm run build:css`?

Tailwind and runtime asset builds belong to the gems, chiefly `al_folio_core`.
The starter keeps only visual-regression and cross-gem integration checks.
See [BOUNDARIES.md](BOUNDARIES.md).

### A feature is configured but renders nothing. Why?

Feature gating has two layers, and both must be satisfied: the gem must be present in the `plugins:` list and its `_config.yml` flag on, and the page's own front matter must ask for it.
When a gem or flag is missing, the tag emits an empty string, so features fail silently rather than loudly.

### Jupyter notebooks are enabled but the build says `jupyter-nbconvert` is missing

Install the Python side yourself, from `requirements.txt`; Bundler cannot do it, and there is no `bin/setup-python-deps` in this fork.
A missing `nbconvert` is warn-and-continue: the build finishes and notebook rendering is skipped.

### How does the sidebar table of contents work?

Front matter, per page:

```yaml
toc:
  sidebar: left # or right
  collapse: expanded # or auto
```

Tocbot is loaded from the pinned CDN entry in `_config.yml` under `third_party_libraries.tocbot`.

### Legacy Bootstrap markup

Set `al_folio.compat.bootstrap.enabled: true` and keep `al_folio_bootstrap_compat` in the plugin list.
Supported through v1.2, deprecated in v1.3, removed in v2.0, so migrate content off `data-toggle` and Bootstrap classes before then.

### Why does `pretty_table: true` still work with Bootstrap compatibility off?

A vanilla Tailwind table engine handles `table[data-toggle="table"]` markup, with search, pagination, sortable columns and click-to-select, so Bootstrap Table is not needed.

### How do I change icon library versions?

Icons come from pinned CDN URLs in `_config.yml` under `third_party_libraries`, with SRI hashes.
Change the version and the hash together, or the browser will silently refuse the file.
