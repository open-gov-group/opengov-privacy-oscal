# OpenGov Privacy – (MVP)

This initiative delivers a standards-based way to document and assess privacy/security for public-sector processing activities:
OSCAL artifacts (Catalog, Profile, Component Definition, SSP) for a GDPR/ISO-aligned privacy baseline.
A mapping pipeline that converts administrative sources (xDOMEA Aktenplan, BPMN) into a Common Information Model (CIM) and finally into an OSCAL SSP.
A lightweight Reader UI to view SSP/POA&M and attach evidence metadata (Back-Matter resources).

## Overview
This initiative provides a standards-based, automatable path to GDPR/ISO-aligned privacy documentation for public administration.

- **OSCAL content** (Catalog, Profile, Component Definition, SSP) derived from SDM (DSK), CNIL, ISO/IEC 29100/29134/27018/27701.
- **Mappings pipeline** to convert xDOMEA Aktenplan + BPMN into a **Common Information Model (CIM)**, then to **OSCAL SSP**.
- **Reader UI** to view SSP/POA&M and attach evidence metadata (Back-Matter).
- **Contracts & registries** to make mapping rules, vocabularies, and API surfaces explicit.

## Repositories
- **opengov-privacy-oscal** – Authoritative OSCAL artifacts (catalog, profiles, components, SSP templates).

        Authoritative OSCAL content.
        Catalog: Privacy controls from SDM (DSK), CNIL, ISO/IEC 29100/29134/27018/27701.
        Profiles: Tailoring per Gewährleistungsziel (e.g., Intervenierbarkeit, Datenminimierung).
        Components: Reusable building blocks (DMS, IAM, Lösch-Engine, Backup/Restore).
        SSP templates: RoPA-oriented templates (OSCAL 1.1.2) with Back-Matter hooks.
        Resolved profile (CI): Optional pre-expanded baseline for downstream use.

- **opengov-privacy-mappings** – CLI, rules, and writer to build SSP from inputs; JSON Schema validation.

        Mapping & CLI.
        CIM schema to normalize inputs (Aktenplan, BPMN, vendor docs).
        Rules (YAML) to transform xDOMEA/BPMN → CIM and CIM → SSP.
        Writer/guards: Schema-valid SSP, evidence in Back-Matter (resources[].rlinks[]), cross-refs via links[].
        Tools: Validation against OSCAL JSON Schema (1.1.2).


- **opengov-privacy-app** – React UI to view SSP/POA&M and manage evidence links.

        Reader UI (React + Vite + Tailwind).
        Loads resolved Profile + Catalog + SSP (pinned raw URLs).
        Tabs for SSP, POA&M, Evidence.
        Evidence uploader (metadata only) → Back-Matter (UUID contract).

- **opengov-privacy-contracts** – Mapper contract (YAML), vocab registries, OpenAPI for ingest gateways.

        Contracts & registries.
        Mapper contract (YAML): priorities, normalization, targets into SSP.
        Normalization registries: data-categories, legal-basis, vocab (EN-first, DE aliases).
        OpenAPI for ingest gateways (xDOMEA/BPMN/vendor), read-only MVP.

## Typical Flow
1. **Ingest** xDOMEA (Aktenplan) and BPMN (process) → normalize to CIM.
2. **Write** SSP from CIM using a chosen Profile and evidence fallback.
3. **Validate** SSP against OSCAL 1.1.2 JSON Schema.
4. **Review** in the UI; add evidence references (Back-Matter).
5. **Iterate** mappings/rules and publish updated artifacts.

## License
Apache-2.0 (code) and CC-BY-4.0 (content), unless noted otherwise.

