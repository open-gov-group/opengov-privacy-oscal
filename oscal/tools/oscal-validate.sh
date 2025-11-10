#!/usr/bin/env bash
# Validate SSP → Profile → Catalog chain using jq-only checks.
# Usage: tools/oscal-validate.sh oscal/ssp/ssp_template_ropa.json

set -euo pipefail

SSP_PATH="${1:-oscal/ssp/ssp_template_ropa.json}"

if [[ ! -f "$SSP_PATH" ]]; then
  echo "::error file=$SSP_PATH::SSP file not found"
  exit 1
fi

# -------- Helpers
fetch() {
  # curl + basic error reporting
  local url="$1"
  curl -fsSL "$url"
}
http_head_ok() {
  local url="$1"
  local code
  code="$(curl -s -o /dev/null -w '%{http_code}' "$url")" || true
  [[ "$code" == "200" ]]
}

require_true () {
  local cond="$1"; local msg="$2"
  if ! eval "$cond"; then
    echo "::error::$msg"
    exit 1
  fi
}

# -------- 0) Syntax gate (already done in workflow, but keep here if called standalone)
jq -e . "$SSP_PATH" >/dev/null

# -------- 1) SSP structural checks
TOP_HAS=$(jq -e 'has("system-security-plan")' "$SSP_PATH") || true
require_true "[[ $TOP_HAS == true ]]" "Top-level key 'system-security-plan' missing."

SSP_VERSION=$(jq -r '.["system-security-plan"].metadata["oscal-version"]' "$SSP_PATH")
require_true "[[ ${SSP_VERSION:-} == 1.1.2 ]]" "SSP oscal-version must be 1.1.2 (found: ${SSP_VERSION:-<none>})."

# Required system-characteristics fields
jq -e '
  .["system-security-plan"]["system-characteristics"] as $sc
  | ($sc["system-ids"]|type=="array")
    and ($sc["system-name"]|type=="string")
    and ($sc["description"]|type=="string")
    and ($sc["status"].state|type=="string")
    and ($sc["security-sensitivity-level"]|type=="string")
' "$SSP_PATH" >/dev/null || {
  echo "::error::Missing required fields under system-characteristics (ids/name/description/status/security-sensitivity-level)."
  exit 1
}

# Each component must have status.state
jq -e '
  .["system-security-plan"]["system-implementation"]["components"]
  | ( . == null ) or ( map(has("status") and (.status.state|type=="string")) | all )
' "$SSP_PATH" >/dev/null || {
  echo "::error::Every system-implementation.component requires a status.state."
  exit 1
}

# Collect SSP component UUIDs
SSP_COMPONENTS="$(jq -r '
  .["system-security-plan"]["system-implementation"]["components"] // []
  | map(.uuid) | @sh' "$SSP_PATH")"
# Normalize to array bash-friendly
# shellcheck disable=SC2207
read -r -a SSP_COMPONENT_UUIDS <<< "$(echo "$SSP_COMPONENTS" | sed "s/'//g")"

# -------- 2) Resolve Profile from SSP and fetch
PROFILE_HREF=$(jq -r '.["system-security-plan"]["import-profile"].href // empty' "$SSP_PATH")
require_true "[[ -n ${PROFILE_HREF:-} ]]" "SSP import-profile.href missing."

require_true "http_head_ok \"$PROFILE_HREF\"" "Profile URL not reachable (non-200): $PROFILE_HREF"
PROFILE_JSON="$(fetch "$PROFILE_HREF")"
echo "Fetched Profile: $PROFILE_HREF"

PROFILE_VERSION="$(jq -r '.profile.metadata["oscal-version"] // empty' <<<"$PROFILE_JSON")"
require_true "[[ ${PROFILE_VERSION:-} == 1.1.2 ]]" "Profile oscal-version must be 1.1.2 (found: ${PROFILE_VERSION:-<none>})."

# -------- 3) Resolve Catalog from Profile and fetch
CATALOG_HREF="$(jq -r '.profile.imports[0].href // empty' <<<"$PROFILE_JSON")"
require_true "[[ -n ${CATALOG_HREF:-} ]]" "Profile imports[0].href missing."

require_true "http_head_ok \"$CATALOG_HREF\"" "Catalog URL not reachable (non-200): $CATALOG_HREF"
CATALOG_JSON="$(fetch "$CATALOG_HREF")"
echo "Fetched Catalog: $CATALOG_HREF"

CATALOG_VERSION="$(jq -r '.catalog.metadata["oscal-version"] // empty' <<<"$CATALOG_JSON")"
require_true "[[ ${CATALOG_VERSION:-} == 1.1.2 ]]" "Catalog oscal-version must be 1.1.2 (found: ${CATALOG_VERSION:-<none>})."

# -------- 4) Build control id sets
PROFILE_CTRL_IDS="$(jq -r '
  .profile.imports
  | map(.["include-controls"] // [])
  | flatten
  | map(.["with-ids"] // [])
  | flatten
  | unique | @sh' <<<"$PROFILE_JSON")"
read -r -a PROFILE_CONTROLS <<< "$(echo "$PROFILE_CTRL_IDS" | sed "s/'//g")"

# Catalog IDs present?
missing_in_catalog=0
for cid in "${PROFILE_CONTROLS[@]:-}"; do
  exists=$(jq -r --arg cid "$cid" '
    [ .catalog.groups[].controls[] | select(.id==$cid) ] | length' <<<"$CATALOG_JSON")
  if [[ "$exists" -eq 0 ]]; then
    echo "::error::Profile includes control '$cid' but it does not exist in Catalog."
    missing_in_catalog=1
  fi
done
require_true "[[ $missing_in_catalog -eq 0 ]]" "Some profile controls are missing from the catalog."

# -------- 5) SSP implemented-requirements must be subset of profile controls
SSP_CTRL_IDS="$(jq -r '
  .["system-security-plan"]["control-implementation"]["implemented-requirements"] // []
  | map(."control-id") | unique | @sh' "$SSP_PATH")"
read -r -a SSP_CONTROLS <<< "$(echo "$SSP_CTRL_IDS" | sed "s/'//g")"

subset_ok=1
for cid in "${SSP_CONTROLS[@]:-}"; do
  found=0
  for pcid in "${PROFILE_CONTROLS[@]:-}"; do
    [[ "$pcid" == "$cid" ]] && found=1 && break
  done
  if [[ $found -eq 0 ]]; then
    echo "::error::SSP implements control '$cid' which is not included by the imported Profile."
    subset_ok=0
  fi
done
require_true "[[ $subset_ok -eq 1 ]]" "SSP control-ids must be subset of Profile include-controls."

# -------- 6) Validate each statement-id exists as a statement part in Catalog
stmt_missing=0
# Iterate over every implemented requirement and statement
count_ir=$(jq -r '.["system-security-plan"]["control-implementation"]["implemented-requirements"] | length' "$SSP_PATH")
for ((i=0; i<count_ir; i++)); do
  cid=$(jq -r ".\"system-security-plan\".\"control-implementation\".\"implemented-requirements\"[$i].\"control-id\"" "$SSP_PATH")
  count_stmt=$(jq -r ".\"system-security-plan\".\"control-implementation\".\"implemented-requirements\"[$i].statements | length" "$SSP_PATH" 2>/dev/null || echo 0)
  for ((j=0; j<count_stmt; j++)); do
    sid=$(jq -r ".\"system-security-plan\".\"control-implementation\".\"implemented-requirements\"[$i].statements[$j].\"statement-id\"" "$SSP_PATH")
    # Check in catalog
    exists=$(jq -r --arg cid "$cid" --arg sid "$sid" '
      [ .catalog.groups[].controls[]
        | select(.id==$cid)
        | .parts[]? | select(.name=="statement" and .id==$sid)
      ] | length' <<<"$CATALOG_JSON")
    if [[ "$exists" -eq 0 ]]; then
      echo "::error::Statement-id '$sid' not found as a 'statement' part under control '$cid' in Catalog."
      stmt_missing=1
    fi
  done
done
require_true "[[ $stmt_missing -eq 0 ]]" "Some statement-ids referenced by the SSP were not found in the Catalog."

# -------- 7) Validate by-components reference existing components
ref_missing=0
jq -r '
  .["system-security-plan"]["control-implementation"]["implemented-requirements"] // []
  | .[] | (.statements // []) | .[]
  | (.["by-components"] // []) | .[]
  | .["component-uuid"]
' "$SSP_PATH" | while read -r cuid; do
  # shellcheck disable=SC2076
  if [[ ! " ${SSP_COMPONENT_UUIDS[*]-} " =~ " ${cuid} " ]]; then
    echo "::error::by-components.component-uuid '${cuid}' not found among system-implementation.components[].uuid."
    ref_missing=1
  fi
done
require_true "[[ ${ref_missing:-0} -eq 0 ]]" "Some by-components.component-uuid references do not exist."

echo "All SSP ↔ Profile ↔ Catalog checks passed ✅"
