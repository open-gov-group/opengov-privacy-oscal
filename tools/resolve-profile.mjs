#!/usr/bin/env node
import fs from "node:fs/promises";

if (process.argv.length < 5) {
  console.error("usage: node tools/resolve-profile.mjs <profile.json> <catalog.json> <out.json>");
  process.exit(1);
}

const [,, profilePath, catalogPath, outPath] = process.argv;

const profile = JSON.parse(await fs.readFile(profilePath, "utf-8"));
const catalog = JSON.parse(await fs.readFile(catalogPath, "utf-8"));

/** collect included control IDs from profile (simple case) */
function collectIncludedIds(p) {
  // OSCAL 1.1.x typical shape:
  // profile.imports[].include-controls[].with-ids[]  (sometimes with-ids or with-controls)
  const imports = p?.profile?.imports || [];
  const ids = new Set();
  for (const imp of imports) {
    const includes = imp?.["include-controls"] || [];
    for (const inc of includes) {
      const list = inc?.["with-ids"] || inc?.["with-controls"] || [];
      for (const w of list) {
        const v = w?.["control-id"] || w?.id || w;
        if (v) ids.add(v);
      }
    }
  }
  return ids;
}

/** deep-filter catalog groups/controls by id set */
function filterCatalog(cat, idSet) {
  const input = cat?.catalog || cat; // support already-rooted
  const out = {
    catalog: {
      uuid: input.uuid || crypto.randomUUID?.() || String(Date.now()),
      metadata: input.metadata,
      groups: []
    }
  };
  // ensure metadata.oscal-version is present
  out.catalog.metadata ||= {};
  out.catalog.metadata["oscal-version"] ||= "1.1.2";

  const groups = input.groups || [];
  for (const g of groups) {
    const ng = { id: g.id, title: g.title, controls: [] };
    const controls = g.controls || [];
    for (const c of controls) {
      if (idSet.has(c.id)) {
        ng.controls.push(c);
      }
    }
    // keep group if it still has controls
    if (ng.controls.length) out.catalog.groups.push(ng);
  }
  return out;
}

const ids = collectIncludedIds(profile);
if (!ids.size) {
  console.error("No included control IDs found in profile. Check profile.imports/include-controls.");
  process.exit(2);
}

const resolved = filterCatalog(catalog, ids);
await fs.writeFile(outPath, JSON.stringify(resolved, null, 2));
console.log(`Resolved catalog written: ${outPath} (controls=${[...ids].length})`);
