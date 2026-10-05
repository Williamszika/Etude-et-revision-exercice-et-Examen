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

# Pausen (seit 03.10.2026): Pausentage zählen im Plan nicht mit. Gerechnet wird nur in
# heute.py. Seite und App bekommen den *wirksamen* Start — 11.09. plus die Pausentage bis
# heute —, damit ihre alte Formel t = (heute − start) wieder die richtige Lektion ergibt.
import sys as _sys
_sys.path.insert(0, BASE)
import heute as kalender  # noqa: E402
_heute = kalender.heute_berlin()
if lekt:
    START = kalender.effektiver_start(_heute).isoformat()
ETAPPE_ENDE = kalender.etappe_ende().isoformat()
PAUSEN = [{'von': p['von'], 'bis': p['bis'], **({'zaehlt': True} if p.get('zaehlt') else {})}
          for p in kalender._roh()]

# Seit 05.10.2026: ihr persönliches Fehlerheft (wird bei jeder Korrektur ergänzt) und
# ob die Einstufungsmessung 1 noch offen ist (dann zeigt die Seite einen Hinweis).
_fp = os.path.join(BASE, 'fehlerheft.json')
FEHLER = json.load(open(_fp, encoding='utf-8')).get('fehler', []) if os.path.exists(_fp) else []
try:
    _ein = json.load(open(os.path.join(BASE, 'einstufungen.json'), encoding='utf-8'))
    MESSUNG_OFFEN = any(m.get('status') == 'offen' for m in _ein.get('messungen', []))
except Exception:
    MESSUNG_OFFEN = False

data = json.dumps(lekt, ensure_ascii=False).replace('</', '<\\/')
tpl = open(os.path.join(BASE, '_template.html'), encoding='utf-8').read()
out = (tpl.replace('__DATA__', data).replace('__START__', START)
          .replace('__ENDE__', ETAPPE_ENDE)
          .replace('__ENDE_LANG__', '.'.join(reversed(ETAPPE_ENDE.split('-'))))
          .replace('__PAUSEN__', json.dumps(PAUSEN))
          .replace('__FEHLER__', json.dumps(FEHLER, ensure_ascii=False).replace('</', '<\\/'))
          .replace('__MESSUNG_OFFEN__', 'true' if MESSUNG_OFFEN else 'false'))
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
            'wortart': w.get('wortart') or '',
            'niveau': w.get('niveau') or '',
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
    'lektionenGesamt': 72,
    'themenGesamt': 29,
    'etappeEnde': ETAPPE_ENDE,
    'pausen': PAUSEN,
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
