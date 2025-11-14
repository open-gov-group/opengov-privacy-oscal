# OpenGov Privacy – OSCAL Content

## Overview
This repository is the **authoritative source** for all OSCAL artifacts of our privacy catalog. The goal is a **Grundschutz-like, EU-compliant** privacy baseline (GDPR, ISO/IEC 29100/29134/27018/27701, DSK’s SDM, CNIL) that can be reused across business applications and integrated into **System Security Plans (SSP)**.

## Background & Vision
Public administrations already maintain rich information (file plans/xDOMEA, BPMN process descriptions, TOM evidence). With **OSCAL** (Open Security Controls Assessment Language) we standardize:
- **requirements formulation** (Catalog),
- **tailoring** (Profile),
- **reusable building blocks** (Component Definition),
- and the **system documentation** (SSP), including evidence references.

This creates a uniform, machine-readable basis for documentation, assessments, and reuse.

## Standards & Sources
- **GDPR** (Art. 5 ff., data subject rights, deletion, accountability)
- **ISO/IEC 29100/29134/27018/27701**, **ISO/IEC 27001 Annex A** (privacy/security controls)
- **SDM** by the German Data Protection Conference (guarantee objectives & methodology)
- **CNIL recommendations** (complementary privacy controls)

## Repository Artifacts
- **Catalog** (`oscal/catalog/*.json`)  
  Contains controls with `parts` (e.g., *statement*, *guidance*, *objective*, optional *criteria*). Organized by guarantee objectives (e.g., intervenability, data minimization).
- **Profiles** (`oscal/profiles/*.json`)  
  Tailoring rules (*include/exclude/alter*) for use cases (e.g., “Intervenability only”).
- **Components** (`oscal/components/*.json`)  
  Reference building blocks (DMS, IAM, erasure engine, backup/restore) incl. stubs for `control-implementations`.
- **SSP Templates** (`oscal/ssp/*.json`)  
  RoPA-oriented templates with `import-profile`, minimal system characteristics, and back-matter hooks.
- **Overlays** (`overlays/*.json`)  
  Language overlays (e.g., DE) for labels/help text.
- **Build (optional)** (`build/profile_resolved_catalog.json`)  
  CI artifact: a resolved profile as a flat catalog for viewers/downstream tools.

## Directory Layout
oscal/
catalog/
profiles/
components/
ssp/
overlays/
build/ # (optional) CI output, e.g., resolved profile


## Conventions & Compatibility
- **OSCAL version**: 1.1.2 (viewer compatibility)
- **Evidence**: via `back-matter.resources[].rlinks[]` in artifacts; referenced at implementation level using `links[]` (no `related-resources` in SSP).
- **IDs & references**: stable per-object `uuid`; prefer **canonical raw URLs** (e.g., `https://raw.githubusercontent.com/...`).

## Usage Scenarios
### A) Browse catalog/profile (viewer)
1. Load `oscal/catalog/opengov_privacy_catalog.json` in an OSCAL viewer.  
2. Optionally use `build/profile_resolved_catalog.json` (flat, faster).  
3. Load profiles (`oscal/profiles/*.json`) as the baseline.

### B) Create an SSP (downstream)
1. Select an appropriate **profile** (`oscal/profiles/*.json`).  
2. Copy an **SSP template** (`oscal/ssp/*.json`) and set `import-profile.href`.  
3. Populate system characteristics and components; add evidence in `back-matter.resources` and reference via `links[]` in implementations.  
4. Validate against the JSON Schema (see CI).

## CI/Validation
- **JSON syntax checks** and **OSCAL schema validation** (1.1.2).  
- Optional **resolve-profile** step generating `build/profile_resolved_catalog.json`.  
- URL linting (e.g., canonicalization of GitHub raw links).

## Contribution & Maintenance
- Propose new controls/guidance as PRs to **Catalog**.  
- Tailoring changes as PRs to **Profiles**.  
- Keep common building blocks (DMS/IAM/…) in **Components**.  
- Always cite sources (standards/guidance) in Issues/PRs.

## License
- **Catalog/Profile content**: CC-BY-4.0 (unless noted otherwise)  
- **Helper scripts/CI**: Apache-2.0
