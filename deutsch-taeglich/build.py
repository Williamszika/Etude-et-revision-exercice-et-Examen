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

# ---- Wortschatzseite: alle Vokabeln aller Lektionen an einem Ort ----------------------
# Quelle sind die Bloecke `vokabeln` (Vokabeln des Tages) und, wo es die noch nicht gibt,
# die Wortschatztabelle im `lesen`-Block. Nichts erfinden — nur zusammentragen.
def woerter_aus(d):
    raus, gesehen = [], set()
    def nimm(w, quelle):
        wort = (w.get('de') or w.get('wort') or '').strip()
        if not wort or wort in gesehen:
            return
        gesehen.add(wort)
        raus.append({
            'de': wort,
            'fr': w.get('fr', ''),
            'wortart': w.get('wortart') or w.get('niveau') or '',
            'beispiel': w.get('beispiel') or w.get('imText') or '',
            'beispielFr': w.get('beispielFr', ''),
            'quelle': quelle,
        })
    for w in (d.get('vokabeln') or {}).get('woerter') or []:
        nimm(w, 'vokabeln')
    for w in ((d.get('lesen') or {}).get('wortschatz') or {}).get('woerter') or []:
        nimm(w, 'lesen')
    return raus

ws = []
for d in lekt:
    ww = woerter_aus(d)
    if not ww:
        continue
    z = d.get('zyklus') or {}
    ws.append({
        'datum': d['datum'],
        'lektion': z.get('lektion'),
        'thema': z.get('thema', ''),
        'titel': (d.get('vokabeln') or {}).get('titel') or 'Wörter aus der Lektion',
        'woerter': ww,
    })

wtpl = open(os.path.join(BASE, '_wortschatz.html'), encoding='utf-8').read()
wout = wtpl.replace('__DATA__',
                    json.dumps(ws, ensure_ascii=False).replace('</', '<\\/'))
open(os.path.join(BASE, 'wortschatz.html'), 'w', encoding='utf-8').write(wout)
print(f"Wortschatz: {sum(len(x['woerter']) for x in ws)} Wörter aus {len(ws)} Lektion(en) "
      f"· HTML: {round(len(wout)/1024)} KB")
