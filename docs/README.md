# Documentation

Guides for the Bayesian Governance Lab website.
The site is a customised fork of the [al-folio](https://github.com/alshedivat/al-folio) v1.x starter, so some pages here describe the theme rather than this site; each says which it is.

## This site

- [Quick Start](QUICKSTART.md): add yourself to the people page, or make a small content change.
- [Installing and Deploying](INSTALL.md): local setup, the production build, and `deploy.sh`.
- [Troubleshooting](TROUBLESHOOTING.md): what actually goes wrong here, and how to tell.
- [FAQ](FAQ.md): shorter answers to the same.
- [Contributing](CONTRIBUTING.md): how a lab member gets a change onto the site.

## The theme

- [Customizing](CUSTOMIZE.md): feature configuration, layouts, publications, CVs.
  This is upstream's guide, lightly corrected; treat its GitHub Pages and Actions material as not applicable here.
- [Analytics](ANALYTICS.md) and [SEO](SEO.md): provider setup, both optional and mostly unused on this site.
- [Ownership Boundaries](BOUNDARIES.md): which repository owns what, starter versus plugin gems.

## How this fork differs from upstream al-folio

Worth knowing before following any theme documentation:

- **The site is not on GitHub Pages.** It is served from Oxford web space at `https://www.robots.ox.ac.uk/~mosb/bgl/`, and `baseurl` is `/~mosb/bgl`.
- **Nothing deploys automatically.** There are no GitHub Actions workflows in this repository; `./deploy.sh` is the only thing that changes the live site.
- **There is no Docker path.** The `Dockerfile`, compose files and devcontainer were removed, along with the `bin/` scripts they depended on.
- **`_posts` is empty.** The site has no blog; news items live in `_news/`.
- **The starter style contract fails by design**, because this site owns `_includes` and `_sass` locally. See `.al-folio-overrides.yml`.
