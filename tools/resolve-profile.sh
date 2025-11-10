#!/usr/bin/env bash
set -euo pipefail

PROFILE_URL="${1:?usage: resolve-profile.sh <profile-url>}"
OUT="${2:-build/profile_resolved_catalog.json}"

mkdir -p "$(dirname "$OUT")"

echo "Fetching profile: $PROFILE_URL"
PROFILE_JSON="$(curl -fsSL "$PROFILE_URL")"

OSCAL_VER="$(jq -r '.profile.metadata["oscal-version"]' <<<"$PROFILE_JSON")"
if [[ "$OSCAL_VER" != "1.1.2" ]]; then
  echo "warn: profile oscal-version=$OSCAL_VER (expected 1.1.2)"
fi

CAT_URL="$(jq -r '.profile.imports[0].href' <<<"$PROFILE_JSON")"
echo "Fetching catalog: $CAT_URL"
CAT_JSON="$(curl -fsSL "$CAT_URL")"

# IDs aus dem Profile sammeln (nur include-controls.with-ids)
mapfile -t IDS < <(jq -r '.profile.imports | map(.["include-controls"] // []) | flatten | map(.["with-ids"] // []) | flatten | unique[]?' <<<"$PROFILE_JSON")

# In JSON-Array umwandeln (["B1-1","B1-2",...]); auch mit leerer Liste korrekt
IDS_JSON="$(printf '%s\n' "${IDS[@]-}" | jq -R . | jq -s .)"

# jq-Resolve: filtere Katalog-Gruppen auf die gewünschten Controls
# (nur include-IDs; kein alter/merge/with-controls-by-class)
jq \
  --argjson cat "$CAT_JSON" \
  --argjson ids "$IDS_JSON" \
  '
  def keep_ids($ids):
    .groups = (
      .groups
      | map(
          .controls = (
            (.controls // [])
            | map(select(.id as $cid | $ids | index($cid)))
          )
        )
      | map(select((.controls // []) | length > 0))
    )
    | .
  ;

  { catalog: ( $cat.catalog | keep_ids($ids) ) }
  ' \
  > "$OUT"

echo "Resolved catalog written to $OUT ✅"
