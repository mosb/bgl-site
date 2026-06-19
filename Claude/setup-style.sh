#!/usr/bin/env bash
# Seed al-folio's gem-owned theme SCSS into _sass/, then wire in the BGL
# overrides via an @import so future edits to _sass/_bgl_overrides.scss apply
# automatically. Run once from the repo root: bash bin/setup-style.sh
set -euo pipefail
CORE=$(bundle show al_folio_core)
mkdir -p _sass
for p in _themes _variables; do
  src=$(find "$CORE" -name "${p}.scss" 2>/dev/null | head -1)
  if [ -n "${src:-}" ] && [ ! -f "_sass/${p}.scss" ]; then
    cp "$src" "_sass/${p}.scss" && echo "seeded _sass/${p}.scss from gem"
  fi
done
if [ ! -f _sass/_bgl_overrides.scss ]; then
  echo "ERROR: copy _sass/_bgl_overrides.scss into place first." >&2; exit 1
fi
if ! grep -q 'bgl_overrides' _sass/_themes.scss 2>/dev/null; then
  printf '\n@import "bgl_overrides";\n' >> _sass/_themes.scss
  echo 'added @import "bgl_overrides"; to _sass/_themes.scss'
else
  echo "import already present; nothing to do"
fi
