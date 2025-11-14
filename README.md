# OpenGov Privacy – OSCAL Inhalte

[![VALIDATE](https://github.com/open-gov-group/opengov-privacy-oscal/actions/workflows/validate.yml/badge.svg)](https://github.com/open-gov-group/opengov-privacy-oscal/actions/workflows/validate.yml) [![VALIDATE](https://github.com/open-gov-group/opengov-privacy-oscal/actions/workflows/validate.yml/badge.svg)](https://github.com/open-gov-group/opengov-privacy-oscal/actions/workflows/validate-oscal.yml)

A public, EU-ready privacy catalog and templates in **OSCAL** for public sector use — derived from **SDM (DSK)**, **CNIL guidance**, and **ISO/IEC 29100 / 29134 / 27018 / 27701**.  
This repository is the canonical source for the **OpenGovGroup Privacy Catalog**, tailored **Profiles**, reusable **Components**, and a RoPA-oriented **SSP** template.

> Version: 0.2.0 · Last updated: 2025-11-01

---

## Überblick
Dieses Repository stellt die **autoritative Quelle** für alle OSCAL-Artefakte unseres Datenschutz-Katalogs bereit. Ziel ist ein **grundschutz-ähnlicher, EU-konformer** Baseline-Katalog (GDPR/DSGVO, ISO/IEC 29100/29134/27018/27701, SDM der DSK, CNIL), der von Fachverfahren wiederverwendet und in **System Security Plans (SSP)** integriert werden kann.

## Hintergrund & Zielbild
Öffentliche Verwaltungen halten zahlreiche Informationen bereits vor (Aktenplan/xDOMEA, Prozessbeschreibungen/BPMN, TOM-Nachweise). Durch **OSCAL** (Open Security Controls Assessment Language) standardisieren wir:
- die **Formulierung von Anforderungen** (Catalog),
- deren **Tailoring** (Profile),
- **wiederverwendbare Bausteine** (Component Definition),
- und die **Systemdokumentation** (SSP), inkl. Evidenz-Verweisen.

Damit entsteht eine einheitliche, maschinenlesbare Grundlage für Dokumentation, Prüfung und Wiederverwendung.

## Standards & Quellen
- **DSGVO/GDPR** (Art. 5 ff., Betroffenenrechte, Löschung, Rechenschaftspflicht)
- **ISO/IEC 29100/29134/27018/27701**, **ISO/IEC 27001 Anhang A** (Privacy-/Security-Kontrollen)
- **SDM** der Datenschutzkonferenz (Gewährleistungsziele & Methodik)
- **CNIL-Empfehlungen** (ergänzende Privacy-Kontrollen)

## Artefakte im Repository
- **Catalog** (`oscal/catalog/*.json`)  
  Enthält Kontrollen und deren `parts` (z. B. *statement*, *guidance*, *objective*, optional *criteria*). Aufbau orientiert sich an Gewährleistungszielen (z. B. Intervenierbarkeit, Datenminimierung).
- **Profiles** (`oscal/profiles/*.json`)  
  Enthalten Tailoring-Regeln (*include/exclude/alter*) für Anwendungsfälle (z. B. nur „Intervenierbarkeit“).
- **Components** (`oscal/components/*.json`)  
  Referenz-Bausteine (DMS, IAM, Lösch-Engine, Backup/Restore) inkl. Platzhaltern für `control-implementations`.
- **SSP-Vorlagen** (`oscal/ssp/*.json`)  
  RoPA-orientierte Templates mit `import-profile`, minimalen Systemmerkmalen und Back-Matter-Hooks.
- **Overlays** (`overlays/*.json`)  
  Sprachüberlagerungen (z. B. DE) für Bezeichnungen/Hilfetexte.
- **Build (optional)** (`build/profile_resolved_catalog.json`)  
  CI-Artefakt: voraufgelöstes Profil als flacher Katalog für Viewer/Downstream Tools.

## Verzeichnisstruktur

oscal/
catalog/
profiles/
components/
ssp/
overlays/
build/ # (optional) CI-Ausgabe, z. B. resolved profile


## Konventionen & Kompatibilität
- **OSCAL-Version**: 1.1.2 (Viewer-Kompatibilität)
- **Evidenz**: ausschließlich über `back-matter.resources[].rlinks[]` in Artefakten; Referenzierung auf Implementierungsebene via `links[]` (kein `related-resources` im SSP).
- **IDs & Referenzen**: stabile `uuid` pro Objekt; URLs als **kanonische Raw-Links** (z. B. `https://raw.githubusercontent.com/...`).

## Nutzungsszenarien
### A) Katalog/Profil betrachten (Viewer)
1. `oscal/catalog/opengov_privacy_catalog.json` im OSCAL-Viewer laden.  
2. Optional: `build/profile_resolved_catalog.json` verwenden (flach, schneller).  
3. Profile (`oscal/profiles/*.json`) als Baseline einblenden.

### B) SSP aufsetzen (Downstream)
1. Passendes **Profil** auswählen (`oscal/profiles/*.json`).  
2. **SSP-Template** (`oscal/ssp/*.json`) kopieren und `import-profile.href` setzen.  
3. Systemmerkmale und Komponenten befüllen; Evidenz in `back-matter.resources` hinterlegen und über `links[]` auf Implementierungen referenzieren.  
4. Mit JSON-Schema validieren (siehe CI).

## CI/Validierung
- **Syntax-Check** (JSON) und **OSCAL-Schema-Validierung** (1.1.2).  
- Optionales **Resolve-Profile** erzeugt `build/profile_resolved_catalog.json`.  
- Linting-Hinweise zu URLs (z. B. Canonicalisierung von GitHub-Raw-Links).

## Beitrag & Pflege
- Neue Kontrollen/Guidance als PR gegen **Catalog**.  
- Tailoring als PR gegen **Profiles**.  
- Gemeinsame Bausteine (DMS/IAM/…) als **Components** pflegen.  
- Änderungen stets über **Issues/PRs** mit Quellenangabe (Norm/Leitlinie).

## Lizenz
- **Katalog-/Profil-Inhalte**: CC-BY-4.0 (sofern nicht anders vermerkt)  
- **Hilfsskripte/CI**: Apache-2.0


