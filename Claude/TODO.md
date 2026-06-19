# Bayesian Governance Lab — build checklist (flat, numbered)

Work top to bottom. Paths are relative to your fork root
(/Users/mosb/Documents/WWW/bgl-site). Run `sv` after the edits to check, then
`./deploy.sh` to publish.

1. Copy `_pages/about.md` from this kit over the fork's `_pages/about.md`.
2. Copy `_pages/research.md` into `_pages/` (new page).
3. Copy `_pages/profiles.md` over the fork's `_pages/profiles.md`.
4. Copy `_pages/about_maike.md` into `_pages/` (bio referenced by profiles).
5. Copy `_pages/publications.md` over the fork's `_pages/publications.md`.
6. Copy `_pages/join.md` into `_pages/` (new page).
7. Copy `_bibliography/papers.bib` over the fork's `_bibliography/papers.bib`.
8. Copy `_data/socials.yml` over the fork's `_data/socials.yml`.
9. Copy `_data/venues.yml` over the fork's `_data/venues.yml`.
10. Copy `_news/announcement_1.md` over the fork's `_news/announcement_1.md`.
11. Copy `deploy.sh` to the fork root and run `chmod +x deploy.sh`.
12. Open `_config.yml` and apply every key in `_config-changes.yml` (merge, do not overwrite the whole file).
13. Delete demo page `_pages/about_einstein.md`.
14. Delete demo page `_pages/books.md`.
15. Delete demo page `_pages/cv.md`.
16. Delete demo page `_pages/dropdown.md`.
17. Delete demo page `_pages/plugins.md`.
18. Delete demo page `_pages/projects.md`.
19. Delete demo page `_pages/repositories.md`.
20. Delete demo page `_pages/teaching.md`.
21. Delete demo page `_pages/blog.md`.
22. Delete demo posts: `rm -f _posts/*`.
23. Delete demo collections: `rm -rf _projects _books`.
24. Delete any demo news you did not write in `_news/` (keep `announcement_1.md`).
25. Delete unused demo data: `_data/cv.yml`, `_data/coauthors.yml`, `_data/repositories.yml`, `_data/citations.yml`, `_data/featured_plugins.yml`.
26. Delete demo images in `assets/img/`: the numbered `1.jpg`–`12.jpg`, `rhino*`, `book_covers/`, `publication_preview/`, `template_error*`, and any leftover `*-480/800/1400.webp` built from them.
27. Add `assets/img/prof_pic.jpg` — the lab logo or a hero image (referenced by `about.md`).
28. Add `assets/img/maike.jpg` — the director photo (referenced by `profiles.md`); the `maike_photo.jpg` from your ~mosb site works.
29. Run `sv` and open http://127.0.0.1:4000/~bgl/ — confirm a clean build (no Conflict, no stack trace).
30. Check the about, research, people, publications, and join pages render and the navbar order reads research, people, publications, join.
31. Check the publications page: 12 entries, newest first, four flagged as selected appear on the homepage, and the coloured venue labels show.
32. Check MathJax, dark mode, and that internal links resolve under `/~bgl/`.
33. Replace the placeholder text in `about.md`, `research.md`, and `about_maike.md` with the lab's real wording.
34. When happy, run `./deploy.sh` and confirm at https://www.robots.ox.ac.uk/~bgl/.
35. Ask the Oxford Martin web team to link the lab from the AI Governance Initiative page, and add a link from your ~mosb sidebar.

## Images and styling (added)

36. Copy `bin/fetch-images.sh` and `bin/setup-style.sh` into `bin/`, then `chmod +x bin/*.sh`.
37. Run `bash bin/fetch-images.sh` to download the three Unsplash photos into `assets/img/` (hero-mountains.jpg, ridges-blue.jpg, layers-silhouette.jpg).
38. Copy `_pages/credits.md` into `_pages/` (the image credits page).
39. Add a link to `/credits/` in the footer (footer_text in `_config.yml`).
40. Copy `_sass/_bgl_overrides.scss` into `_sass/`.
41. Run `bash bin/setup-style.sh` once to seed al-folio's theme SCSS from the gem and append the BGL palette overrides.
42. Re-run `sv` and confirm the purple/pink accents apply and the publications BibTeX blocks render in Source Code Pro.
43. Optional: enable the per-heading colours or the karmina (Typekit) fonts by uncommenting their blocks in `_sass/_bgl_overrides.scss`.
44. Use `ridges-blue.jpg` or `layers-silhouette.jpg` as headers on the research or publications pages if you want more imagery (same `<img>` + credit pattern as about.md).

## Logo and brand colours (added)

45. Copy the provided `assets/img/logo.png` into your fork's `assets/img/` (rasterised from your BXL_circle.pdf, transparent background; it is the about-page profile image).
46. Copy the provided `assets/img/favicon.ico`, `assets/img/favicon.png`, and `assets/img/apple-touch-icon.png` into `assets/img/` (generated from the logo). al-folio v1 may still favour the emoji `icon:` in `_config.yml`; if the favicon does not pick up, keep the emoji or check the head/icon docs.
47. The brand palette (purple #8159a4, cyan #60c4bf, orange #f19c39, red #cb5763, blue #6e8dd7) is already in `_sass/_bgl_overrides.scss` and `_data/venues.yml`. If you ran an earlier version of `bin/setup-style.sh` that pasted colours into `_sass/_themes.scss`, delete `_sass/_themes.scss` and re-run the script so it wires the live `@import` instead.
48. Re-run `sv` and confirm the logo shows on the about page, links are brand purple, and publication labels carry the brand colours.
