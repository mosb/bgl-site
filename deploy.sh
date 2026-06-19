#!/usr/bin/env bash
# Build the Bayesian Governance Lab site and deploy to www.robots.ox.ac.uk/~bgl
# Mirrors your ~mosb publish function: Homebrew rsync into the WWW directory.
set -euo pipefail

# ── Settings: confirm these against the ~bgl account ──────────────────────
RSYNC="/opt/homebrew/bin/rsync"          # Homebrew rsync (system macOS rsync
                                         # is too old for --iconv / --chmod)
REMOTE_USER="bgl"
REMOTE_HOST="login.robots.ox.ac.uk"
REMOTE_DIR="WWW"
# ──────────────────────────────────────────────────────────────────────────

echo "Building site (production)…"
JEKYLL_ENV=production bundle exec jekyll build

TARGET="${REMOTE_USER}@${REMOTE_HOST}:~/${REMOTE_DIR}"

# Same flags as your ~mosb function: recurse, preserve times, verbose, compress,
# set sane web permissions, skip macOS cruft and large video, fix HFS encoding.
RSYNC_FLAGS=(
  -rtvz
  --chmod=D755,F644
  --exclude='.DS_Store' --exclude='._*'
  --exclude='*.mp4' --exclude='*.mov' --exclude='*.m4v'
  --iconv=UTF-8-MAC,UTF-8
)

echo
echo "Dry run — these changes WOULD be made (nothing written yet):"
"${RSYNC}" "${RSYNC_FLAGS[@]}" --dry-run _site/ "${TARGET}"

echo
read -r -p "Proceed with deploy to ${TARGET}? [y/N] " ok
if [[ "${ok}" != "y" && "${ok}" != "Y" ]]; then
  echo "Aborted; no changes made."
  exit 1
fi

"${RSYNC}" "${RSYNC_FLAGS[@]}" _site/ "${TARGET}"
echo "Done → https://www.robots.ox.ac.uk/~bgl/"
