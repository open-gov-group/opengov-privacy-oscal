# OpenGov Privacy OSCAL

[![VALIDATE](https://github.com/open-gov-group/opengov-privacy-oscal/actions/workflows/validate.yml/badge.svg)](https://github.com/open-gov-group/opengov-privacy-oscal/actions/workflows/validate.yml)

A public, EU-ready privacy catalog and templates in **OSCAL** for public sector use — derived from **SDM (DSK)**, **CNIL guidance**, and **ISO/IEC 29100 / 29134 / 27018 / 27701**.  
This repository is the canonical source for the **OpenGovGroup Privacy Catalog**, tailored **Profiles**, reusable **Components**, and a RoPA-oriented **SSP** template.

> Version: 0.2.0 · Last updated: 2025-11-01

---

## Goals
- Provide a **Grundschutz-like privacy catalog** in OSCAL with GDPR-aligned controls.
- Enable **profiles** for scopes (e.g., Intervenability, Confidentiality, Data Minimization, or specific line-of-business systems).
- Offer **component definitions** (DMS, IAM, Export Service, Erasure Engine, Backup/Restore) for reuse across SSPs.
- Deliver an **SSP (RoPA) template** to maintain Records of Processing in OSCAL.
- Support **multilingual overlays** (DE/…​) without duplicating the canonical catalog.

## Repository Structure
```
oscal/
  catalog/
    opengov_privacy_catalog.json
  profiles/
    profile_intervenability.json
    profile_confidentiality.json
    profile_data_minimization.json
  components/
    components_reference.json
  ssp/
    ssp_template_ropa.json
overlays/
  profile_translation_de.json
docs/
tools/
.github/workflows/
  validate.yml
LICENSE
README.md
```

## How to Use (viewer.oscal.io)
1. **Load the catalog**: `oscal/catalog/opengov_privacy_catalog.json`  
2. **Load a profile** (optional, recommended): e.g., `oscal/profiles/profile_intervenability.json`  
3. **Load the component definition**: `oscal/components/components_reference.json` (to inspect reusable building blocks)  
4. **Load the SSP template**: `oscal/ssp/ssp_template_ropa.json` (as the RoPA starting point)  
5. **German labels**: additionally load `overlays/profile_translation_de.json` (non-destructive props overlay)

> All imports use **relative paths** so you can download the repo and open files locally in the viewer.

## IDs, Mapping & Method
- **Control IDs** keep SDM-style identifiers (e.g., `B1-10`).
- **Groups** reflect **Gewährleistungsziele** (Tp, Iv, Vt, Ig, Vf, Dm, Nn).
- **Props** include references to CNIL and ISO/IEC 29100/29134/27018/27701 for traceability.
- **Parts**: `statement`, `guidance`, nested `objective` parts, optional `criteria`.
- **Profiles** tailor subsets for auditing or solution scope (as-is merge).
- **Components** define reusable implementations (`control-implementations`).
- **SSP** holds RoPA-relevant properties and links implementations via `by-components`.

## Roadmap
- Expand catalog families: **Legal basis**, **Processors & DPAs**, **DPIA**, **Breach**, **Transfers**, **RoPA**, **Privacy by Design/Default**, **Security (TOM)**.
- Add **profiles** per family and per **line-of-business** domain.
- Add **vendor-neutral** and **vendor-specific** components with evidence resources.
- Add **translation overlays** (FR/IT/ES) using the same pattern as `profile_translation_de.json`.

## Contributing
1. Fork and create a feature branch.
2. Follow **ID & prose conventions** (English canonical; translations via overlays).
3. Run CI (JSON lint). For schema validation, add NIST OSCAL tooling in `validate.yml`.
4. Open a PR; reviewers: privacy, security, and public-sector SMEs.

## License
- **Text & schema content**: Apache-2.0 (see `LICENSE`).
- Please ensure external excerpts are cited and compatible with the license.

---

**Maintainers:** open-gov.group · Contact: info@open-gov.group
