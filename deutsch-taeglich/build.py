#!/usr/bin/env python3
"""Baut deutsch-taeglich/index.html aus allen Lektionen in lektionen/*.json (neueste zuerst)."""
import os, json, glob

BASE = os.path.dirname(os.path.abspath(__file__))
lekt = []
for f in sorted(glob.glob(os.path.join(BASE, 'lektionen', '*.json')), reverse=True):
    try:
        d = json.load(open(f, encoding='utf-8'))
        # Eine Lektion braucht ein Datum und mindestens einen Lernbaustein.
        # An den Übungstagen (Zyklus Tag 2-5) gibt es bewusst kein neues
        # verb/wortschatz/grammatik — dort steht nur das training.
        bausteine = ('verb', 'wortschatz', 'grammatik', 'satzbau',
                     'training', 'diktat', 'aussprache', 'uebersetzung')
        if 'datum' in d and any(k in d for k in bausteine):
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
