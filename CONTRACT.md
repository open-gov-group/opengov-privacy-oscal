# OpenGov Privacy – Contracts

This document defines two contracts used by the UI and tooling.

## 1) OSCAL Contract (JSON)

**File:** `oscal/contract.json` (also referenced from SSP back-matter as `res-contract`)

### Purpose
- Pin resolved profile & catalog URLs for the app.
- Provide risk matrices & i18n URLs.
- Provide ruleset URLs (YAML) for mapping external sources into SSP.

### Schema (informal)
```json
{
  "contractVersion": "1.0",
  "oscalVersion": "1.1.2",
  "title": "string",
  "sources": {
    "profile": { "resolvedUrl": "url", "sourceUrl": "url", "sha256": "hex?" },
    "catalog": { "url": "url" },
    "risk": { "qualitativeCsv": "url", "quantitativeJson": "url" },
    "i18n": { "de": "url", "en": "url" },
    "rulesets": [
      { "id": "string", "description": "string", "yamlUrl": "url", "priority": 10 }
    ]
  },
  "ui": { "preferredViewer": "url", "defaultLang": "de|en" }
}
