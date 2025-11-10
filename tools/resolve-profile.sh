#!/usr/bin/env bash
set -euo pipefail

PROFILE_URL="${1:?usage: resolve-profile.sh <profile-url>}"
OUT="${2:-build/profile_resolved_catalog.json}"

mkdir -p "$(dirname "$OUT")"

echo "Fetching profile: $PROFILE_URL"
PROFILE_JSON="$(curl -fsSL "$PROFILE_URL")"

OSCAL_VER="$(jq -r '.profile.metadata["oscal-version"]' <<<"$PROFILE_JSON")"
[[ "$OSCAL_VER" == "1.1.2" ]] || echo "warn: profile oscal-version=$OSCAL_VER (expected 1.1.2)"

CAT_URL="$(jq -r '.profile.imports[0].href' <<<"$PROFILE_JSON")"
echo "Fetching catalog: $CAT_URL"
CAT_JSON="$(curl -fsSL "$CAT_URL")"

# Controls, die das Profile inkludiert (mit-ids). (Einfache Variante ohne 'alter', 'merge', 'include-by-class' etc.)
mapfile -t IDS < <(jq -r '.profile.imports | map(.["include-controls"] // []) | flatten | map(.["with-ids"] // []) | flatten | unique[]' <<<"$PROFILE_JSON")

jq -n --argjson cat "$CAT_JSON" '
  { catalog:
    $cat.catalog
    | .groups = ( .groups
        | map(
            .controls = ( .controls
              | map(select([.id] | inside($ENV.IDS | split("\n"))))
            )
          )
        | map(select(.controls|length>0))
      )
  }' IDS="$(printf "%s\n" "${IDS[@]-}")" > "$OUT"

echo "Resolved catalog written to $OUT ✅"
