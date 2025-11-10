#!/usr/bin/env bash
set -euo pipefail
SSP_PATH="${1:-oscal/ssp/ssp_template_ropa_full.json}"

if [[ ! -f "$SSP_PATH" ]]; then echo "::error file=$SSP_PATH::SSP file not found"; exit 1; fi
fetch() { curl -fsSL "$1"; }
http_head_ok() { local code; code="$(curl -s -o /dev/null -w '%{http_code}' "$1")" || true; [[ "$code" == "200" ]]; }
require_true () { if ! eval "$1"; then echo "::error::$2"; exit 1; fi; }

jq -e . "$SSP_PATH" >/dev/null
TOP_HAS=$(jq -e 'has("system-security-plan")' "$SSP_PATH") || true
require_true "[[ $TOP_HAS == true ]]" "Top-level key 'system-security-plan' missing."

SSP_VERSION=$(jq -r '.["system-security-plan"].metadata["oscal-version"]' "$SSP_PATH")
require_true "[[ ${SSP_VERSION:-} == 1.1.2 ]]" "SSP oscal-version must be 1.1.2 (found: ${SSP_VERSION:-<none>})."

jq -e '.["system-security-plan"]["system-characteristics"] as $sc
| ($sc["system-ids"]|type=="array")
and ($sc["system-name"]|type=="string")
and ($sc["description"]|type=="string")
and ($sc["status"].state|type=="string")
and ($sc["security-sensitivity-level"]|type=="string")' "$SSP_PATH" >/dev/null || {
  echo "::error::Missing required fields under system-characteristics"; exit 1; }

jq -e '.["system-security-plan"]["system-implementation"]["components"]
| ( . == null ) or ( map(has("status") and (.status.state|type=="string")) | all )' "$SSP_PATH" >/dev/null || {
  echo "::error::Every component requires a status.state."; exit 1; }

SSP_COMPONENTS="$(jq -r '.["system-security-plan"]["system-implementation"]["components"] // [] | map(.uuid) | @sh' "$SSP_PATH")"
read -r -a SSP_COMPONENT_UUIDS <<< "$(echo "$SSP_COMPONENTS" | sed "s/'//g")"

PROFILE_HREF=$(jq -r '.["system-security-plan"]["import-profile"].href // empty' "$SSP_PATH")
require_true "[[ -n ${PROFILE_HREF:-} ]]" "SSP import-profile.href missing."
require_true "http_head_ok \"$PROFILE_HREF\"" "Profile URL not reachable (non-200): $PROFILE_HREF"

PROFILE_JSON="$(fetch "$PROFILE_HREF")"
PROFILE_VERSION="$(jq -r '.profile.metadata["oscal-version"] // empty' <<<"$PROFILE_JSON")"
require_true "[[ ${PROFILE_VERSION:-} == 1.1.2 ]]" "Profile oscal-version must be 1.1.2 (found: ${PROFILE_VERSION:-<none>})."

CATALOG_HREF="$(jq -r '.profile.imports[0].href // empty' <<<"$PROFILE_JSON")"
require_true "[[ -n ${CATALOG_HREF:-} ]]" "Profile imports[0].href missing."
require_true "http_head_ok \"$CATALOG_HREF\"" "Catalog URL not reachable (non-200): $CATALOG_HREF"

CATALOG_JSON="$(fetch "$CATALOG_HREF")"
CATALOG_VERSION="$(jq -r '.catalog.metadata["oscal-version"] // empty' <<<"$CATALOG_JSON")"
require_true "[[ ${CATALOG_VERSION:-} == 1.1.2 ]]" "Catalog oscal-version must be 1.1.2 (found: ${CATALOG_VERSION:-<none>})."

PROFILE_CTRL_IDS="$(jq -r '.profile.imports | map(.["include-controls"] // []) | flatten | map(.["with-ids"] // []) | flatten | unique | @sh' <<<"$PROFILE_JSON")"
read -r -a PROFILE_CONTROLS <<< "$(echo "$PROFILE_CTRL_IDS" | sed "s/'//g")"

missing_in_catalog=0
for cid in "${PROFILE_CONTROLS[@]:-}"; do
  exists=$(jq -r --arg cid "$cid" '[ .catalog.groups[].controls[] | select(.id==$cid) ] | length' <<<"$CATALOG_JSON")
  if [[ "$exists" -eq 0 ]]; then echo "::error::Profile includes control '"$cid"' but it does not exist in Catalog."; missing_in_catalog=1; fi
done
require_true "[[ $missing_in_catalog -eq 0 ]]" "Some profile controls are missing from the catalog."

SSP_CTRL_IDS="$(jq -r '.["system-security-plan"]["control-implementation"]["implemented-requirements"] // [] | map(."control-id") | unique | @sh' "$SSP_PATH")"
read -r -a SSP_CONTROLS <<< "$(echo "$SSP_CTRL_IDS" | sed "s/'//g")"
subset_ok=1
for cid in "${SSP_CONTROLS[@]:-}"; do
  found=0; for pcid in "${PROFILE_CONTROLS[@]:-}"; do [[ "$pcid" == "$cid" ]] && found=1 && break; done
  if [[ $found -eq 0 ]]; then echo "::error::SSP implements control '"$cid"' which is not included by the imported Profile."; subset_ok=0; fi
done
require_true "[[ $subset_ok -eq 1 ]]" "SSP control-ids must be subset of Profile include-controls."

stmt_missing=0
count_ir=$(jq -r '.["system-security-plan"]["control-implementation"]["implemented-requirements"] | length' "$SSP_PATH")
for ((i=0; i<count_ir; i++)); do
  cid=$(jq -r ".\"system-security-plan\".\"control-implementation\".\"implemented-requirements\"[$i].\"control-id\"" "$SSP_PATH")
  count_stmt=$(jq -r ".\"system-security-plan\".\"control-implementation\".\"implemented-requirements\"[$i].statements | length" "$SSP_PATH" 2>/dev/null || echo 0)
  for ((j=0; j<count_stmt; j++)); do
    sid=$(jq -r ".\"system-security-plan\".\"control-implementation\".\"implemented-requirements\"[$i].statements[$j].\"statement-id\"" "$SSP_PATH")
    exists=$(jq -r --arg cid "$cid" --arg sid "$sid" '[ .catalog.groups[].controls[] | select(.id==$cid) | .parts[]? | select(.name=="statement" and .id==$sid) ] | length' <<<"$CATALOG_JSON")
    if [[ "$exists" -eq 0 ]]; then echo "::error::Statement-id '"$sid"' not found as a 'statement' part under control '"$cid"' in Catalog."; stmt_missing=1; fi
  done
done
require_true "[[ $stmt_missing -eq 0 ]]" "Some statement-ids referenced by the SSP were not found in the Catalog."

ref_missing=0
jq -r '.["system-security-plan"]["control-implementation"]["implemented-requirements"] // [] | .[] | (.statements // []) | .[] | (.["by-components"] // []) | .[] | .["component-uuid"]' "$SSP_PATH" \
| while read -r cuid; do
  if [[ " ${SSP_COMPONENT_UUIDS[*]-} " != *" ${cuid} "* ]]; then echo "::error::by-components.component-uuid '"$cuid"' not found among system-implementation.components[].uuid."; ref_missing=1; fi
done
require_true "[[ ${ref_missing:-0} -eq 0 ]]" "Some by-components.component-uuid references do not exist."

echo "All SSP ↔ Profile ↔ Catalog checks passed ✅"
