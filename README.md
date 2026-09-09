# Bayesian Governance Lab website

Source for the website of the [Bayesian Governance Lab](https://www.robots.ox.ac.uk/~mosb/bgl/) at the University of Oxford: probabilistic machine learning for the assurance, monitoring, and governance of AI systems.

The site is built with [Jekyll](https://jekyllrb.com/) on the [al-folio](https://github.com/alshedivat/al-folio) theme (v1, with the theme's layouts and styling supplied by the `al_folio_*` gems).
Almost everything you might want to change is plain content in this repository; you should not need to touch the theme.

## Adding your profile

Lab members appear on the [people page](https://www.robots.ox.ac.uk/~mosb/bgl/people/), which is rendered from a single data file.
To add yourself:

1. **Edit [`_data/members.yml`](_data/members.yml).** Copy the commented template block at the bottom and fill it in.
   The fields (`name`, `role`, `image`, `blurb`, `links`) are documented at the top of the file.
   List order is display order.
2. **Add a photo to [`assets/img/`](assets/img/).** A square JPEG or PNG crops best; around 600×600 px is plenty.
   Browsers cannot display HEIC, so export from Apple Photos as JPEG first.
   Set the `image` field to the bare filename.
   If you omit it, you get a neutral placeholder tile.
3. **Open a pull request** with both changes.
   Maike will review, merge, and deploy.

Note that deployment is manual (see below), so your profile appears on the live site the next time Maike deploys, not the moment the PR is merged.

## Other things you can edit

| What                | Where                                                                                           |
| ------------------- | ----------------------------------------------------------------------------------------------- |
| Publications        | [`_bibliography/papers.bib`](_bibliography/papers.bib), following the style of existing entries |
| News items          | [`_news/`](_news/), as short markdown files shown on the front page                             |
| Pages (about, join) | [`_pages/`](_pages/)                                                                            |

For publications, keep given names initialised, include the abstract, and add `arxiv`/`doi`/`url` links where they exist, matching the entries already in the file.

## Previewing locally

With Ruby installed:

```bash
bundle install
bundle exec jekyll serve
```

then open <http://localhost:4000/~mosb/bgl/> (the site lives under the `/~mosb/bgl` base path, so the bare `localhost:4000` root will 404).

A local preview is nice but not required for a profile PR; the YAML file is forgiving, and it gets checked before deployment anyway.

## Deployment

The live site is served from `www.robots.ox.ac.uk/~mosb/bgl` and deployed by `deploy.sh`, which builds the site and rsyncs `_site/` to the Oxford web space.
Only Maike can run it; merged changes reach the live site on the next deploy.

## Theme

Built on [al-folio](https://github.com/alshedivat/al-folio), MIT licence.
[`docs/`](docs/) covers both: [INSTALL.md](docs/INSTALL.md) and [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) describe this site, while [CUSTOMIZE.md](docs/CUSTOMIZE.md) is the theme's own customisation guide.
Note that this fork is not on GitHub Pages and has no CI, so upstream material about Actions, `gh-pages` and Docker does not apply; [docs/README.md](docs/README.md) lists the differences.
