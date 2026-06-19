#!/usr/bin/env bash
# Download the suggested Unsplash images into assets/img/.
# Run locally from the repo root (needs internet access to unsplash.com):
#   bash bin/fetch-images.sh
set -euo pipefail
mkdir -p assets/img
dl () {  # dl <unsplash-photo-id> <target-filename>
  echo "Fetching assets/img/$2 ..."
  curl -L --fail -o "assets/img/$2" "https://unsplash.com/photos/$1/download?w=1920"
}
dl A1IoRfRQHuk hero-mountains.jpg     # Marek Piwnicki
dl O8Y4TPR2tEk ridges-blue.jpg        # 志远 杨 (Zhiyuan Yang)
dl e1JXtCOsKTw layers-silhouette.jpg  # Claudio Schwarz
echo "Done. Credits are in _pages/credits.md."
