# Quick Start

For lab members who want to appear on the site, or to change something small.
You do not need Ruby, Jekyll, or any local setup for this.

## Add yourself to the people page

1. **Edit [`_data/members.yml`](../_data/members.yml).**
   Copy the commented template block at the bottom of the file and fill it in.
   The fields (`name`, `role`, `status`, `group`, `image`, `blurb`, `links`) are documented at the top of the same file.
   List order is display order.

2. **Add a photo to [`assets/img/`](../assets/img/).**
   A square JPEG or PNG crops best, and 600x600 px is plenty.
   Browsers cannot display HEIC, so export from Apple Photos as JPEG first.
   Set `image` to the bare filename.
   Omit it and you get a tile with your initials instead, which is a perfectly good option.

3. **Open a pull request** with both changes.
   Maike reviews, merges, and deploys.

Your blurb should be one to three sentences on what you work on.
Write it in the third person without pronouns, as the existing entries do, and it will read consistently with the rest of the page.

## Change something else

| What                | Where                                                                                              |
| ------------------- | -------------------------------------------------------------------------------------------------- |
| Publications        | [`_bibliography/papers.bib`](../_bibliography/papers.bib), following the style of existing entries |
| News items          | [`_news/`](../_news/), as short markdown files shown on the front page                             |
| Pages (about, join) | [`_pages/`](../_pages/)                                                                            |

For publications, keep given names initialised, include the abstract, and add `arxiv`, `doi` or `url` links where they exist.

## When will it appear?

Not at merge time.
Deployment is manual, so a merged change reaches the live site the next time Maike runs `./deploy.sh`.

## If you want to preview locally

See [INSTALL.md](INSTALL.md).
It is not required for a profile change: YAML is forgiving, and the build is checked before deployment anyway.
