# Troubleshooting

Failure modes this site actually has.
For the theme's own features, [CUSTOMIZE.md](CUSTOMIZE.md) is the reference; for setup and deployment, [INSTALL.md](INSTALL.md).

## The live site did not change

Almost always because nothing deployed.
Pushing to `origin` publishes nothing here: there are no Actions workflows, and `./deploy.sh` is the only path to the live site.
Check what is actually live rather than trusting the build:

```bash
curl -fsS https://www.robots.ox.ac.uk/~mosb/bgl/people/ | grep "the text you expect"
```

## The page is stale or unstyled in the browser, but correct on the server

Fetch the deployed asset and look at it:

```bash
curl -fsS https://www.robots.ox.ac.uk/~mosb/bgl/assets/css/main.css | grep "the rule you expect"
```

If the rule is there, the browser is holding an old copy.
Stylesheet links carry a content hash (`main.css?v=...`), but not every browser treats a changed query string as a new resource, so a hard reload or a cache purge is the fix.
This has bitten before, with an old stylesheet rendering the people-page initials uncentred long after the current one was live.

## The build works locally but the deployed site has no styling

Suspect `baseurl`.
It must stay `/~mosb/bgl` in `_config.yml`, and the production build must be run without a `--baseurl` flag.
Upstream documentation says to build with `--baseurl /al-folio`, which is right for the al-folio demo and wrong here: every CSS, JS and image URL on the built pages comes out pointing at a path that does not exist on the server.

## `deploy.sh` reports rsync errors, or hangs

- **It stops without writing anything.** That is the confirmation prompt.
  It needs a terminal, so it cannot be answered from a script or an agent.
  Run the rsync directly in that case, `--dry-run` first.
- **SSH refuses.** Access to `login.robots.ox.ac.uk` needs a working key or agent. `ssh -o BatchMode=yes mosb@login.robots.ox.ac.uk true` tells you whether that part works, without involving rsync.
- **The dry run lists far more files than you changed.** Normal.
  Jekyll rewrites every file on each build, so mtimes change and rsync re-sends.
  What matters in the dry run is the `deleting` lines, since `--delete` makes the remote mirror `_site/` exactly.

## A member photo does not appear

- The file must be in `assets/img/`, and `image:` in `_data/members.yml` must be the bare filename.
- HEIC will not render in any browser.
  Export as JPEG.
- Filenames are case-sensitive on the server even when they are not on macOS.
- Omitting `image:` is a supported choice, not a failure: the card falls back to a tile with the member's initials.

To check what actually loaded rather than what should have, open the page and look at the `img` elements' `naturalWidth`; zero means the file 404'd.

## `npm run lint:style-contract` fails

Expected, and not something to fix:

```
- Starter must not own core component path `_includes`
- Starter must not own core component path `_sass`
```

This site owns both deliberately.
See [INSTALL.md § Tracking local overrides](INSTALL.md#tracking-local-overrides).
A third violation, or a different one, is worth reading properly.

## `npm run lint:prettier` fails on `_config.yml`

Also expected.
The comments in that file are hand-aligned, and prettier wants them collapsed to a single space.
Do not run `prettier --write` over it unless you are content to lose the alignment.

## Publications not showing

- The file is `_bibliography/papers.bib`, and each entry needs a unique key.
- A missing comma or unmatched brace silently drops the entry rather than failing the build. `bundle exec jekyll build 2>&1 | grep -i bibtex` surfaces most of these.
- A `pdf={my-paper.pdf}` field expects the file at `assets/pdf/my-paper.pdf`.

## News items not showing

News lives in `_news/`, one short markdown file per item, each with front matter.
`_posts/` is empty and the site has no blog, so a file dropped there renders nowhere.

## YAML errors in `_data/members.yml`

The build fails with a line number, which is usually enough.
The two recurring causes are an unquoted colon inside a string, and a blurb indented inconsistently under `blurb: >-`.
Every blurb line must sit at the same indentation.

```bash
ruby -ryaml -e 'YAML.load_file("_data/members.yml")'
```

parses the file on its own, away from the rest of the build.

## Port 4000 already in use

```bash
lsof -i :4000 | grep LISTEN | awk '{print $2}' | xargs kill
bundle exec jekyll serve --port 5000
```

## Ruby dependency trouble

`bundle install` installs what `Gemfile.lock` pins.
Change a pin deliberately with `bundle update <gem-name>`, then build and look at the site: nothing else will catch a regression.
