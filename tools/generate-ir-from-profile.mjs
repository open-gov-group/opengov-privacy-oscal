#!/usr/bin/env node
import fs from 'node:fs/promises';

if (process.argv.length < 4) {
  console.error('usage: node tools/generate-ir-from-profile.mjs <resolved-profile.json> <out-ir.json>');
  process.exit(1);
}

const [ , , profilePath, outPath ] = process.argv;
const profile = JSON.parse(await fs.readFile(profilePath, 'utf-8'));

// erwartet: resolved Profile mit .profile.controls (oder .catalog.controls wenn schon gemerged)
const controls = profile?.profile?.controls || profile?.catalog?.controls || [];
const ir = controls.flatMap(ctrl => {
  const cid = ctrl.id || ctrl['control-id'] || ctrl['control-id-ref'] || ctrl['id'];
  if (!cid) return [];
  const statements = (ctrl.parts || [])
    .filter(p => (p.name === 'statement' || p.name?.endsWith('_stmt')))
    .map(p => ({ 'statement-id': p.id || `${cid}_stmt` }));
  return [{
    'uuid': crypto.randomUUID?.() || Math.random().toString(16).slice(2),
    'control-id': cid,
    'statements': statements.length ? statements : [{ 'statement-id': `${cid}_stmt` }]
  }];
});

await fs.writeFile(outPath, JSON.stringify({ 'implemented-requirements': ir }, null, 2));
console.log(`Wrote ${ir.length} implemented-requirements → ${outPath}`);
