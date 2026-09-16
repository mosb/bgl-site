#!/usr/bin/env bash
# Build the Bayesian Governance Lab site and deploy to www.robots.ox.ac.uk/~mosb/bgl
# Mirrors your ~mosb publish function: Homebrew rsync into the WWW directory.
#
# Usage: ./deploy.sh [-y|--yes]
#   -y  skip the confirmation prompt (the dry run is still printed), for
#       non-interactive runs where no TTY is available.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

# ── Settings: confirm these against the ~mosb account ──────────────────────
RSYNC="/opt/homebrew/bin/rsync"          # Homebrew rsync (system macOS rsync
                                         # is too old for --iconv / --chmod)
REMOTE_USER="mosb"
REMOTE_HOST="login.robots.ox.ac.uk"
REMOTE_DIR="WWW/bgl"                     # relative to the remote home directory
SITE_URL="https://www.robots.ox.ac.uk/~mosb/bgl"
# ──────────────────────────────────────────────────────────────────────────

ASSUME_YES=0
for arg in "$@"; do
  case "${arg}" in
    -y|--yes) ASSUME_YES=1 ;;
    *) echo "usage: $0 [-y|--yes]" >&2; exit 2 ;;
  esac
done

echo "Building site (production)…"
JEKYLL_ENV=production bundle exec jekyll build

TARGET="${REMOTE_USER}@${REMOTE_HOST}:~/${REMOTE_DIR}"

# Same flags as your ~mosb function: recurse, preserve times, verbose, compress,
# set sane web permissions, skip macOS cruft and large video, fix HFS encoding.
RSYNC_FLAGS=(
  -rtvz
  --delete-delay                         # remote mirrors _site exactly; review
                                         # the dry run before confirming.
                                         # Deletions happen after all transfers,
                                         # so the live tree is never left
                                         # missing a file part-way through.
  --perms --chmod=D755,F644              # --chmod alone only shapes NEW files:
                                         # existing files keep their old mode
                                         # (man rsync, --chmod). With --perms
                                         # every file in the transfer gets
                                         # 644/755, whatever the source tree
                                         # or an earlier deploy left behind.
  --exclude='.DS_Store' --exclude='._*'
  --exclude='*.mp4' --exclude='*.mov' --exclude='*.m4v'
  --iconv=UTF-8-MAC,UTF-8
)

echo
echo "Dry run — these changes WOULD be made (nothing written yet):"
# rsync exit 23 (e.g. an undeletable excluded dir) must not abort before the
# prompt under set -e
"${RSYNC}" "${RSYNC_FLAGS[@]}" --dry-run _site/ "${TARGET}" ||
  echo "WARNING: dry run reported errors (see above); review before proceeding."

echo
if [[ "${ASSUME_YES}" -eq 1 ]]; then
  echo "Proceeding without prompt (--yes)."
else
  read -r -p "Proceed with deploy to ${TARGET}? [y/N] " ok
  if [[ "${ok}" != "y" && "${ok}" != "Y" ]]; then
    echo "Aborted; no changes made."
    exit 1
  fi
fi

"${RSYNC}" "${RSYNC_FLAGS[@]}" _site/ "${TARGET}" ||
  echo "WARNING: rsync reported errors; the deploy may be incomplete."

# Belt and braces on the server side. The web server runs as www-data on
# another host and reads the tree over NFS, so it needs search permission on
# every ancestor directory and read permission on every file. rsync only sets
# modes on what it transfers, and can leave the directory it was given alone,
# so make the whole tree world-readable regardless. The remote login shell is
# tcsh: keep this to plain commands joined with semicolons.
echo
echo "Enforcing world-readable permissions on the server…"
ssh "${REMOTE_USER}@${REMOTE_HOST}" \
  "chmod go+x . WWW ; chmod -R u+rwX,go+rX ${REMOTE_DIR} ; find ${REMOTE_DIR} ! -perm -o=r" ||
  echo "WARNING: could not enforce permissions on the server."

# Verify over HTTP rather than trusting the file listing. A URL is retried for
# a while because the web server's NFS attribute cache can lag a just-renamed
# file by some seconds, which Apache reports as 403 Forbidden rather than 404.
check_url() {
  local url="$1" code="000" attempt
  for attempt in 1 2 3 4 5 6; do
    code="$(curl -sS -o /dev/null -w '%{http_code}' "${url}" || echo 000)"
    if [[ "${code}" == "200" ]]; then
      echo "  200 ${url}"
      return 0
    fi
    sleep 5
  done
  echo "  ${code} ${url}   <-- FAILED"
  return 1
}

echo
echo "Checking the live site…"
URLS=()
while read -r loc; do
  URLS+=("${loc}")
done < <(grep -oE '<loc>[^<]+' _site/sitemap.xml | sed 's/<loc>//' | sort -u)
# A stylesheet, a font and an image: assets whose source files have been
# found owner-only (0600) in the past, so they are the canaries for the
# permissions fix above.
URLS+=(
  "${SITE_URL}/assets/css/main.css"
  "${SITE_URL}/assets/fonts/literata-400.woff2"
  "${SITE_URL}/assets/img/logo.png"
)

FAILED=0
for url in "${URLS[@]}"; do
  check_url "${url}" || FAILED=1
done

echo
if [[ "${FAILED}" -eq 1 ]]; then
  echo "Deploy finished but some URLs are not serving 200. Inspect with:"
  echo "  ssh ${REMOTE_USER}@${REMOTE_HOST} 'ls -la ${REMOTE_DIR}'"
  exit 1
fi
echo "Done → ${SITE_URL}/"
