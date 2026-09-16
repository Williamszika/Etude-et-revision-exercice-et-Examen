#!/usr/bin/env python3
"""Baut app/vorschau/index.html — die anklickbare Vorschau der App.

Sie nimmt dieselben Daten wie die App (deutsch-taeglich/app-daten.json), wirft
die Blöcke weg, die die Vorschau nicht zeigt, und setzt den Rest in
_vorlage.html ein.

    python3 app/vorschau/bauen.py
"""
import json, os

HIER = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(HIER))

# Nur diese Blöcke zeigt die Vorschau — das hält die Seite klein und schnell.
BEHALTEN = {'datum', 'zyklus', 'verb', 'vokabeln', 'leben',
            'deklination', 'diktat', 'uebersetzung', 'lesen'}
LESEN_FELDER = ('titel', 'text', 'fragen', 'hilfe')

d = json.load(open(os.path.join(REPO, 'deutsch-taeglich', 'app-daten.json'),
                   encoding='utf-8'))
raus = {k: v for k, v in d.items() if k != 'lektionen'}
lek = []
for l in d['lektionen']:
    n = {k: v for k, v in l.items() if k in BEHALTEN}
    if 'lesen' in n:
        n['lesen'] = {k: v for k, v in n['lesen'].items() if k in LESEN_FELDER}
    lek.append(n)
raus['lektionen'] = lek

js = json.dumps(raus, ensure_ascii=False, separators=(',', ':')).replace('</', '<\\/')
tpl = open(os.path.join(HIER, '_vorlage.html'), encoding='utf-8').read()
ziel = os.path.join(HIER, 'index.html')
open(ziel, 'w', encoding='utf-8').write(tpl.replace('__DATA__', js))
print(f"Vorschau: {len(lek)} Lektion(en) -> app/vorschau/index.html "
      f"({round(os.path.getsize(ziel)/1024)} KB)")
