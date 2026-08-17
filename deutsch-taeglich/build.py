#!/usr/bin/env python3
"""Baut deutsch-taeglich/index.html aus allen Lektionen in lektionen/*.json (neueste zuerst)."""
import os, json, glob

BASE = os.path.dirname(os.path.abspath(__file__))
lekt = []
for f in sorted(glob.glob(os.path.join(BASE, 'lektionen', '*.json')), reverse=True):
    try:
        d = json.load(open(f, encoding='utf-8'))
        if all(k in d for k in ('datum', 'verb', 'wortschatz', 'grammatik')):
            lekt.append(d)
        else:
            print('  ! übersprungen (Felder fehlen):', os.path.basename(f))
    except Exception as e:
        print('  ! ungültiges JSON:', os.path.basename(f), e)

if not lekt:
    raise SystemExit('Keine Lektionen gefunden.')

data = json.dumps(lekt, ensure_ascii=False).replace('</', '<\\/')
tpl = open(os.path.join(BASE, '_template.html'), encoding='utf-8').read()
out = tpl.replace('__DATA__', data)
open(os.path.join(BASE, 'index.html'), 'w', encoding='utf-8').write(out)
print(f"{len(lekt)} Lektion(en) · neueste: {lekt[0]['datum']} · HTML: {round(len(out)/1024)} KB")
