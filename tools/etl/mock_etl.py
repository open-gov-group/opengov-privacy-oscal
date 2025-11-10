#!/usr/bin/env python3
import json, sys, pathlib, copy, datetime

TEMPLATE_SSP = pathlib.Path("oscal/ssp/ssp_template_ropa_full.json")
OUT = pathlib.Path("build/ssp_generated.json")
XDOMEA = pathlib.Path("samples/xdomea.json")
BPMN = pathlib.Path("samples/bpmn.json")

def load(p):
    with open(p, "r", encoding="utf-8") as f:
        return json.load(f)

def save(p, obj):
    p.parent.mkdir(parents=True, exist_ok=True)
    with open(p, "w", encoding="utf-8") as f:
        json.dump(obj, f, ensure_ascii=False, indent=2)

def extract_from_xdomea(x):
    purposes = sorted(set(x.get("records", [{}])[0].get("subjects", ["<purpose-unclassified>"])))
    retention = x.get("retention", {}).get("policy", "policy-defined")
    legal_basis = x.get("legal_basis", ["<Art. 6 GDPR>"])
    recipients = x.get("recipients", ["<internal>"])
    return {
        "purposes": purposes,
        "retention": retention,
        "legal_basis": ", ".join(legal_basis),
        "recipients": ", ".join(recipients)
    }

def extract_from_bpmn(b):
    data_cats = sorted(set([d.get("name","").strip() for d in b.get("dataObjects", []) if d.get("name")]))
    subjects  = sorted(set([lane.get("label","").strip() for lane in b.get("lanes", []) if lane.get("external") is False]))
    ext_rec   = sorted(set([mf.get("targetPool","").strip() for mf in b.get("messageFlows", []) if mf.get("external")]))
    return {
        "data_categories": ", ".join(data_cats) if data_cats else "<categories of personal data>",
        "data_subjects": ", ".join(subjects) if subjects else "<data subject categories>",
        "recipients_ext": ", ".join(ext_rec) if ext_rec else ""
    }

def main():
    ssp = load(TEMPLATE_SSP)
    x = load(XDOMEA) if XDOMEA.exists() else {}
    b = load(BPMN) if BPMN.exists() else {}

    xmap = extract_from_xdomea(x) if x else {}
    bmap = extract_from_bpmn(b) if b else {}

    sc = ssp["system-security-plan"]["system-characteristics"]
    props = {p["name"]: p for p in sc.get("props", [])}

    def set_prop(name, value):
        if name in props:
            props[name]["value"] = value
        else:
            sc.setdefault("props", []).append({"name": name, "value": value})

    # Fill from sources
    if xmap: set_prop("ropa:purpose", ", ".join(xmap["purposes"]))
    if bmap.get("data_categories"): set_prop("ropa:data-categories", bmap["data_categories"])
    if bmap.get("data_subjects"):   set_prop("ropa:data-subjects", bmap["data_subjects"])

    # recipients combine internal and external
    rec = []
    if xmap.get("recipients"): rec.append(xmap["recipients"])
    if bmap.get("recipients_ext"): rec.append(bmap["recipients_ext"])
    if rec: set_prop("ropa:recipients", "; ".join([r for r in rec if r]))

    if xmap.get("retention"):   set_prop("ropa:retention", xmap["retention"])
    if xmap.get("legal_basis"): set_prop("ropa:legal-basis", xmap["legal_basis"])

    # Touch metadata timestamp
    ssp["system-security-plan"]["metadata"]["last-modified"] = datetime.datetime.utcnow().replace(microsecond=0).isoformat() + "Z"

    save(OUT, ssp)
    print(f"Wrote {OUT}")

if __name__ == "__main__":
    main()
