#!/usr/bin/env python3
"""Baut deutsch-taeglich/index.html aus allen Lektionen in lektionen/*.json (neueste zuerst)."""
import os, json, glob, datetime

BASE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(BASE)
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

# Echte Sprachaufnahmen (mit deutsch-taeglich/elevenlabs-audio.py vorher erzeugt).
# Liegt audio/<datum>/diktat.mp3 vor, bekommt der Diktatblock das Feld "audio" und
# die Seite nimmt die Aufnahme statt der Vorlesestimme des Browsers. Die Datei wird
# beim Veroeffentlichen als Begleitdatei neben die Seite gelegt, deshalb steht hier
# nur der relative Pfad — eingebettet wird nichts, die Seite bleibt klein.
tonspuren = []
for d in lekt:
    rel = os.path.join('audio', d['datum'], 'diktat.mp3')
    if d.get('diktat') and os.path.exists(os.path.join(BASE, rel)):
        d['diktat']['audio'] = rel.replace(os.sep, '/')
        tonspuren.append(rel.replace(os.sep, '/'))

# Erster Lektionstag der laufenden Etappe. Steht in einer Lektion (zyklus.start),
# sonst hier — damit die Seite auch ohne Lektion sagen kann, wann es losgeht.
START = '2026-09-11'
if lekt:
    START = (lekt[-1].get('zyklus') or {}).get('start') or START

data = json.dumps(lekt, ensure_ascii=False).replace('</', '<\\/')
tpl = open(os.path.join(BASE, '_template.html'), encoding='utf-8').read()
out = tpl.replace('__DATA__', data).replace('__START__', START)
open(os.path.join(BASE, 'index.html'), 'w', encoding='utf-8').write(out)
print(f"{len(lekt)} Lektion(en) · "
      f"{'neueste: ' + lekt[0]['datum'] if lekt else 'Neustart, Beginn ' + START} · "
      f"HTML: {round(len(out)/1024)} KB")
if tonspuren:
    print(f"  Tonspuren (als Begleitdatei mitveröffentlichen): {', '.join(tonspuren)}")

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

# ---------------------------------------------------------------------------
# app-daten.json — die Datenquelle der Flutter-App
#
# Die App holt sich beim Start genau diese eine Datei von GitHub (raw). Damit
# bekommt sie jede neue Lektion automatisch, sobald die 5:30-Routine committet
# hat — ohne dass eine neue App-Version gebaut werden muss.
#
# Dieselbe Datei liegt zusätzlich als Asset in der App (app/assets/), damit
# der allererste Start auch ohne Netz etwas anzeigt.
# ---------------------------------------------------------------------------
app_daten = {
    'stand': datetime.date.today().isoformat(),
    'start': START,
    'lektionenGesamt': 56,
    'themenGesamt': 21,
    'etappeEnde': '2026-12-31',
    'lektionen': lekt,          # neueste zuerst, wie im Template
}
app_pfad = os.path.join(BASE, 'app-daten.json')
open(app_pfad, 'w', encoding='utf-8').write(
    json.dumps(app_daten, ensure_ascii=False, separators=(',', ':')))

# Und als Asset in die App kopieren, falls der Ordner existiert.
asset = os.path.join(REPO, 'app', 'assets', 'lektionen.json')
if os.path.isdir(os.path.dirname(asset)):
    open(asset, 'w', encoding='utf-8').write(
        json.dumps(app_daten, ensure_ascii=False, separators=(',', ':')))
    print(f"App-Daten: {len(lekt)} Lektion(en) -> app-daten.json und app/assets/ "
          f"({round(os.path.getsize(app_pfad)/1024)} KB)")
else:
    print(f"App-Daten: {len(lekt)} Lektion(en) -> app-daten.json "
          f"({round(os.path.getsize(app_pfad)/1024)} KB)")
