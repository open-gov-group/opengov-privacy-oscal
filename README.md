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

```
oscal/
catalog/
profiles/
components/
ssp/
overlays/
build/ # (optional) CI-Ausgabe, z. B. resolved profile
```

### Maturity-Modell (Reifegrade 1–5)

Der Katalog verwendet ein **CNIL-ähnliches Reifegradmodell** mit einer Skala von **1 bis 5**.  
In den Kontrollen sind typischerweise nur die Zustände für **Level 1, 3 und 5** textlich beschrieben; **Level 2 und 4** sind als Zwischenstufen zu verstehen.

- **Level 1 – initial / ad hoc**  
  Kein oder nur rudimentärer Prozess, Rollen unklar, Umsetzung überwiegend reaktiv.

- **Level 2 – teilweise umgesetzt**  
  Erste Elemente von Level 3 vorhanden, aber noch nicht flächendeckend, nicht stabil im Alltag, stark personenabhängig („mehr als 1, aber klar noch nicht 3“).

- **Level 3 – definiert / etabliert**  
  Prozess/Struktur ist formal beschrieben, Rollen sind geklärt und der Soll-Prozess wird im Normalfall so gelebt.

- **Level 4 – weit fortgeschritten**  
  Die meisten Elemente von Level 5 sind umgesetzt (inkl. Kennzahlen/Reviews), aber noch nicht durchgängig integriert oder systematisch optimiert („mehr als 3, aber noch nicht konsistent auf 5“).

- **Level 5 – optimiert / kontinuierliche Verbesserung**  
  Voll in Governance, Risiko- und Steuerungsprozesse integriert, messbar und über KPIs, Audits, Vorfälle und Lessons Learned kontinuierlich verbessert.

**Bewertungshinweis:**  
Wenn die Praxis näher an Level 1 als an 3 liegt → **Level 1**.  
„Irgendwie vorhanden, aber wackelig“ → **Level 2**.  
Beschreibung für Level 3 passt → **Level 3**.  
Fast Level 5, aber noch nicht überall bzw. nicht konsistent → **Level 4**.  
Level-5-Beschreibung wirklich erfüllt → **Level 5**.

In Tools kann diese Skala z.B. als Radiobutton-Skala 1–5 umgesetzt werden; die textlichen Beschreibungen für Level 1/3/5 stammen direkt aus den `maturity-hints` im Catalog.

### Pattern: Maturity-Hints & Assessment-Questions je Control

Für alle Controls verwenden wir ein einheitliches Schema für **Reifegrad-Hinweise** und **Audit-/Assessment-Fragen**.

#### 1. Maturity-Hints

- Pro Control gibt es genau einen Container-Part `*-maturity` mit:
  - `name: "maturity-hints"`
  - optional kurzer `prose`-Einleitung
  - einer Liste von Sub-Parts für die Level **1, 3 und 5**
- Jeder Level-Sub-Part:
  - hat `name: "maturity-level"`
  - trägt ein `prop` mit `name: "maturity-level"` und dem Wert `1`, `3` oder `5`
  - enthält im `prose` die textliche Beschreibung für diesen Level

**Beispiel (GOV-01):**

```json
{
  "id": "gov-01-maturity",
  "name": "maturity-hints",
  "prose": "CNIL-basiertes Reifegradmodell (Level 1, 3, 5).",
  "parts": [
    {
      "id": "gov-01-maturity-level-01",
      "name": "maturity-level",
      "props": [
        { "name": "maturity-level", "value": "1" }
      ],
      "prose": "Level 1: …"
    },
    {
      "id": "gov-01-maturity-level-03",
      "name": "maturity-level",
      "props": [
        { "name": "maturity-level", "value": "3" }
      ],
      "prose": "Level 3: …"
    },
    {
      "id": "gov-01-maturity-level-05",
      "name": "maturity-level",
      "props": [
        { "name": "maturity-level", "value": "5" }
      ],
      "prose": "Level 5: …"
    }
  ]
}
```

### Control-Pattern: Statement, Reifegrade, typische Maßnahmen, Audit-Fragen

Jedes Control im Katalog folgt (soweit möglich) einem einheitlichen 4-Baustein-Muster:

1. **Statement** – Was ist die Anforderung?
2. **Maturity-Hints** – Wie sehen die Reifegrade (1 / 3 / 5) aus?
3. **Typical-Measures** – Welche typischen Maßnahmen setzen die Anforderung praktisch um?
4. **Assessment-Questions** – Welche Fragen stelle ich im Audit / Self-Assessment?

#### 1. Statement

- Part-ID: `<control-id-lower>-stmt`  
- `name: "statement"`  
- `prose`: kurze, normnahe Beschreibung der Kontrolle

```json
{
  "id": "gov-01-stmt",
  "name": "statement",
  "prose": "Die Organisation definiert eine klare Datenschutzorganisation mit benannten Rollen und Zuständigkeiten."
}
```

### Contribution Checklist (neues Control)

Wenn du ein neues Control anlegst oder ein bestehendes erweiterst, prüfe bitte:

1. **Basis**
   - [ ] Control-ID vergeben (z.B. `GOV-07`) und in der richtigen Gruppe (`GOV`, `INC`, …) einsortiert
   - [ ] `title` gesetzt
   - [ ] `props` mit mindestens:
     - [ ] `dsgvo-article`
     - [ ] `sdm-goal`
     - [ ] `maturity-domain`
     - [ ] `target-maturity`

2. **Statement**
   - [ ] Part `<control-id-lower>-stmt` vorhanden  
     `name: "statement"`, kurzer, klarer Satz: *Was ist die Anforderung?*

3. **Maturity-Hints**
   - [ ] Part `<control-id-lower>-maturity` mit `name: "maturity-hints"`
   - [ ] Unter-Parts für Level **1**, **3**, **5**:
     - [ ] IDs `…-maturity-level-01|03|05`
     - [ ] `name: "maturity-level"`
     - [ ] `props: { "name": "maturity-level", "value": "1|3|5" }`
     - [ ] `prose` beschreibt das jeweilige Level

4. **Typical-Measures**
   - [ ] Part `<control-id-lower>-typical-measures` mit `name: "typical-measures"`
   - [ ] Unter-Parts:
     - [ ] IDs `…-typical-measure-01|02|…`
     - [ ] `name: "typical-measure"`
     - [ ] jede `prose` = **eine** konkrete Maßnahme

5. **Assessment-Questions**
   - [ ] Part `<control-id-lower>-questions` mit `name: "assessment-questions"`
   - [ ] Unter-Parts:
     - [ ] IDs `…-question-01|02|…`
     - [ ] `name: "assessment-question"`
     - [ ] jede `prose` = **eine** Frage (ohne Bullet-Format)

Optional:
- [ ] Quellen-/Referenzlinks in `links` ergänzt (EDPB, DSK, BfDI, CNIL, SDM etc.)
- [ ] Rechtschreibung / Klarheit der Texte kurz gegengecheckt


### Wie nutze ich den Katalog mit einer OSCAL Component Definition?

Der OpenGov Privacy OSCAL Catalog ist **nur der Baukasten** (Catalog-Layer).  
Die konkrete Umsetzung in einer Organisation erfolgt über OSCAL **Component Definitions** und später über einen **System Security/Privacy Plan (SSP)**. 

Ein typisches Vorgehen sieht so aus:

1. **Catalog referenzieren**

   - Verwende den Katalog als `source` in deiner `component-definition`:
     ```json
     "source": "https://raw.githubusercontent.com/open-gov-group/opengov-privacy-oscal/main/oscal/catalog/open_privacy_catalog.json"
     ```
   - Alternativ: nutze die Catalog-UUID, falls du mit aufgelösten Profilen arbeitest.

2. **DSMS-/PIMS-Komponente definieren**

   - Lege eine `component-definition` mit einer organisatorischen Komponente an, z.B.:
     ```json
     {
       "uuid": "…",
       "type": "organizational",
       "title": "Datenschutzmanagementsystem (DSMS)",
       "description": "Zentrale Policies, Prozesse, Rollen und Tools für den Datenschutz."
     }
     ```

3. **Control-Implementierung beschreiben**

   - Unter `control-implementations` referenzierst du Controls aus dem Katalog:
     ```json
     {
       "control-id": "GOV-01",
       "description": "Rollen- und Verantwortlichkeitsmodell für den Datenschutz.",
       "statements": [
         {
           "statement-id": "gov-01-stmt",
           "description": "Konkrete Umsetzung in der Organisation (z.B. Geschäftsordnung, Organigramm, RACI-Matrix)."
         }
       ],
       "props": [
         { "name": "maturity-level", "value": "3" }
       ]
     }
     ```
   - So kannst du nach und nach z.B. `GOV-01`, `GOV-02`, `ACC-01`, `TRAIN-01`, `INC-02` usw. als **implemented requirements** dokumentieren.

4. **Reifegrad (Maturity) hinterlegen**

   - Verwende das Property `maturity-level` (1–5) konsistent mit der globalen Skala im Catalog:
     - `1` = ad hoc,
     - `3` = etabliert,
     - `5` = optimiert (Kontinuierliche Verbesserung).
   - Optional kannst du daraus später Auswertungen oder Dashboards generieren.

5. **Nutzung im System-/Privacy-Plan (SSP)**

   - In einem SSP (z.B. für ein Fachverfahren oder eine Plattform) kannst du die DSMS-Komponente **erben**:
     - „Dieses System nutzt die organisatorische Komponente `Datenschutzmanagementsystem (DSMS)`.“
   - System-spezifische Controls (z.B. zusätzliche TOMs, spezielle DPIA) werden dann ergänzend im SSP beschrieben.

Kurz gesagt:

- **Catalog:** beschreibt, *was* gute Datenschutz-Kontrollen sind.  
- **Component Definition (z.B. DSMS/PIMS):** beschreibt, *wie* eine Organisation diese Kontrollen umsetzt.  
- **SSP:** beschreibt, *welche* Systeme welche Komponenten nutzen und wie die Controls dort konkret wirken.



### Links & related-controls

Auf Control-Ebene nutzen wir das OSCAL-`links`-Feld für zwei Zwecke:

1. **Fachliche Querverweise auf andere Controls**
2. **Externe Quellen / Guidelines**

#### 1. Related Controls

Verwandte Controls im Katalog verlinken wir mit:

- `rel: "related-control"`
- `href: "#<CONTROL-ID>"`
- optionalem `text` mit einer kurzen Begründung

Beispiel (LAW-01 → REG/DPIA):

```json
"links": [
  {
    "href": "#REG-01",
    "rel": "related-control",
    "text": "Begründung: REG-01 ist die zentrale Dokumentationsquelle für Verarbeitungstätigkeiten; dort werden Rechtsgrundlagen je Verarbeitungstätigkeit konkret hinterlegt."
  },
  {
    "href": "#REG-02",
    "rel": "related-control",
    "text": "Begründung: REG-02 definiert Methodik und Verantwortlichkeiten dafür, wie Rechtsgrundlagen im Verzeichnis beschrieben, geprüft und gepflegt werden."
  },
  {
    "href": "#DPIA-01",
    "rel": "related-control",
    "text": "Begründung: In DPIA-01 wird bei Hochrisiko-Verarbeitungen geprüft, ob Rechtsgrundlagen tragfähig sind und welche zusätzlichen Maßnahmen erforderlich sind."
  }
]
```
### Links & related-controls

Auf Control-Ebene nutzen wir das OSCAL-`links`-Feld für zwei Zwecke:

1. **Fachliche Querverweise auf andere Controls**
2. **Externe Quellen / Guidelines**

#### 1. Related Controls

Verwandte Controls im Katalog verlinken wir mit:

- `rel: "related-control"`
- `href: "#<CONTROL-ID>"`
- optionalem `text` mit einer kurzen Begründung

Beispiel (LAW-01 → REG/DPIA):

```json
"links": [
  {
    "href": "#REG-01",
    "rel": "related-control",
    "text": "Begründung: REG-01 ist die zentrale Dokumentationsquelle für Verarbeitungstätigkeiten; dort werden Rechtsgrundlagen je Verarbeitungstätigkeit konkret hinterlegt."
  },
  {
    "href": "#REG-02",
    "rel": "related-control",
    "text": "Begründung: REG-02 definiert Methodik und Verantwortlichkeiten dafür, wie Rechtsgrundlagen im Verzeichnis beschrieben, geprüft und gepflegt werden."
  },
  {
    "href": "#DPIA-01",
    "rel": "related-control",
    "text": "Begründung: In DPIA-01 wird bei Hochrisiko-Verarbeitungen geprüft, ob Rechtsgrundlagen tragfähig sind und welche zusätzlichen Maßnahmen erforderlich sind."
  }
]
```

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


