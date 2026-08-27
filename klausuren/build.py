#!/usr/bin/env python3
"""Baut klausuren/index.html aus klausuren.json (neueste Klausur zuerst)."""
import os, json

BASE = os.path.dirname(os.path.abspath(__file__))
d = json.load(open(os.path.join(BASE, 'klausuren.json'), encoding='utf-8'))

MONATE = ['Januar','Februar','März','April','Mai','Juni','Juli','August',
          'September','Oktober','November','Dezember']

k = sorted(d['klausuren'], key=lambda x: x['datum'], reverse=True)
ges_p, ges_m = 0.0, 0
for x in k:
    j, m, t = x['datum'].split('-')
    x['datum_de'] = f"{int(t)}. {MONATE[int(m)-1]} {j}"
    x['prozent'] = round(x['punkte'] / x['max'] * 100)
    ges_p += x['punkte']; ges_m += x['max']

d['klausuren'] = k
d['anzahl'] = len(k)
d['schnitt'] = round(ges_p / ges_m * 100) if ges_m else 0
d['beste'] = min((x['note'] for x in k), default='—')

data = json.dumps(d, ensure_ascii=False).replace('</', '<\\/')
tpl = open(os.path.join(BASE, '_template.html'), encoding='utf-8').read()
out = tpl.replace('__DATA__', data)
open(os.path.join(BASE, 'index.html'), 'w', encoding='utf-8').write(out)
print(f"OK  {len(k)} Klausur(en) · Schnitt {d['schnitt']} % · HTML: {round(len(out)/1024)} KB")
