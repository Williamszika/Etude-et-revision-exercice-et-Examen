#!/usr/bin/env python3
"""Was ist heute bei Deutsch täglich? — die einzige Stelle, an der das gerechnet wird.

    python3 deutsch-taeglich/heute.py              # heute (Europe/Berlin)
    python3 deutsch-taeglich/heute.py 2026-10-12   # ein beliebiges Datum
    python3 deutsch-taeglich/heute.py --json       # dasselbe als JSON

Antwort ist eine von vier Arten:

    PAUSE        — nichts schreiben (Pausen stehen in pausen.json)
    UEBUNGSTAG   — nichts schreiben
    LEKTIONSTAG  — Lektion schreiben; die Zeile nennt alle zyklus-Felder
    VORHER       — vor dem Start der Etappe

Die Regel aus CLAUDE.md, erweitert um die Pausen (seit 03.10.2026):

    t = (heute − 2026-09-11).days − (Pausentage bis heute)
    t gerade  → Lektionstag, lektion = t // 2 + 1, themaBlock = t // 4 + 1
    t ungerade → Übungstag

Pausentage zählen nicht mit: Der ganze Plan rückt um die Zahl der Pausentage
nach hinten, keine Lektion fällt aus. Die Routinen, build.py und pruefen.py
fragen hier nach, statt selbst zu rechnen.
"""
import json
import os
import sys
from datetime import date, datetime, timedelta

BASE = os.path.dirname(os.path.abspath(__file__))
START = date(2026, 9, 11)
PLAN_ENDE = date(2027, 1, 31)        # Ende der Etappe ohne Pausen
LEKTIONEN_GESAMT = 72
THEMEN_GESAMT = 29

GRAMMATIK = [
    'Verbstellung und Satzklammer',
    'Nebensätze: weil, dass, wenn/als, obwohl, damit',
    'Perfekt und Präteritum',
    'Modalverben in allen Zeiten',
    'Das Kasussystem: Nominativ, Akkusativ, Dativ',
    'Wechselpräpositionen und feste Präpositionen',
    'Adjektivdeklination',
    'Komparativ, Superlativ, Vergleiche',
    'Possessiv-, Demonstrativ- und Indefinitpronomen',
    'Reflexive Verben — Akkusativ und Dativ',
    'Trennbare und untrennbare Verben, Infinitiv mit zu',
    'Verben mit Präpositionen, da- und wo-Komposita',
    'Relativsätze — Nominativ, Akkusativ, Dativ',
    'Infinitiv mit zu, um … zu, ohne … zu',
    'Passiv Präsens und Präteritum',
    'Konjunktiv II — würde, könnte, hätte, wäre',
    'Genitiv und Genitivpräpositionen',
    'Temporale Nebensätze und Plusquamperfekt',
    'Konnektoren auf Position 1',
    'Indirekte Fragen mit ob und W-Wort',
    'Wiederholung — die zehn Fehler, die B1 kosten',
    'Futur I · nicht/nur brauchen … zu',
    'n-Deklination · falls',
    'Partizipien als Adjektive, Adjektive als Nomen',
    'Passiv Perfekt und Passiv mit Modalverben',
    'Konjunktiv II der Vergangenheit, irreale Sätze',
    'Zweiteilige Konnektoren · indem, sodass',
    'Relativsätze mit Präposition, was und wo',
    'Wortbildung',
]
THEMEN = [
    'Angaben zur eigenen Person',
    'Der menschliche Körper, Gesundheit und Körperpflege',
    'Wohnen', 'Orte', 'Tägliches Leben', 'Essen und Trinken',
    'Erziehung, Ausbildung, Lernen', 'Arbeit und Beruf',
    'Geschäfte, Handel, Konsum', 'Dienstleistungen', 'Natur und Umwelt',
    'Reise und Verkehr', 'Freizeit und Unterhaltung',
    'Medien und moderne Informationstechniken',
    'Gesellschaft, Staat, Regierung',
    'Beziehungen zu anderen Menschen und Kulturen',
]
REIHE = ['Leseverstehen', 'Hörverstehen', 'Sprachbausteine',
         'Schriftlicher Ausdruck', 'Mündlicher Ausdruck']
WOCHENTAGE = ['Montag', 'Dienstag', 'Mittwoch', 'Donnerstag',
              'Freitag', 'Samstag', 'Sonntag']


def _d(iso):
    return date.fromisoformat(iso)


def pausen():
    """Liste von (von, bis, grund), beide Tage eingeschlossen."""
    pfad = os.path.join(BASE, 'pausen.json')
    if not os.path.exists(pfad):
        return []
    roh = json.load(open(pfad, encoding='utf-8')).get('pausen', [])
    return [(_d(p['von']), _d(p['bis']), p.get('grund', '')) for p in roh]


def in_pause(d):
    for von, bis, _ in pausen():
        if von <= d <= bis:
            return (von, bis)
    return None


def pausentage_bis(d):
    """Pausentage vom Start bis einschließlich d."""
    n = 0
    for von, bis, _ in pausen():
        if von > d:
            continue
        n += (min(bis, d) - von).days + 1
    return n


def pausentage_gesamt():
    return sum((bis - von).days + 1 for von, bis, _ in pausen())


def effektiver_start(d):
    """Der Start, mit dem die alte Formel t = (d − start) für d wieder stimmt."""
    return START + timedelta(days=pausentage_bis(d))


def etappe_ende():
    return PLAN_ENDE + timedelta(days=pausentage_gesamt())


def t_von(d):
    return (d - START).days - pausentage_bis(d)


def datum_von_t(t):
    """Der (nicht pausierte) Kalendertag, an dem der Plan bei t steht."""
    d = START + timedelta(days=t)
    while in_pause(d) or t_von(d) < t:
        d += timedelta(days=1)
    return d


def status(d):
    p = in_pause(d)
    if p:
        nach = p[1] + timedelta(days=1)
        return {'art': 'PAUSE', 'datum': d.isoformat(), 'von': p[0].isoformat(),
                'bis': p[1].isoformat(), 'weiter': nach.isoformat()}
    t = t_von(d)
    if t < 0:
        return {'art': 'VORHER', 'datum': d.isoformat(), 't': t}
    if t % 2:
        return {'art': 'UEBUNGSTAG', 'datum': d.isoformat(), 't': t,
                'lektionVorher': t // 2 + 1}
    lektion = t // 2 + 1
    z = {'woche': (d - date(2026, 9, 8)).days // 7 + 1, 'gesamt': THEMEN_GESAMT,
         'etappe': 'B1', 'takt': 2}
    if t >= THEMEN_GESAMT * 4:
        z['phase'] = 'Wiederholung'
    else:
        block = t // 4 + 1
        themen_tag = (t // 2) % 2 + 1
        z.update({'thema': THEMEN[(block - 1) % 16], 'themaNr': (block - 1) % 16 + 1,
                  'grammatik': GRAMMATIK[block - 1], 'grammatikNr': block,
                  'themaBlock': block, 'themenTag': themen_tag})
        start_block = datum_von_t(t - 2 * (themen_tag - 1))
    z.update({'tag': WOCHENTAGE[d.weekday()], 'fokus': REIHE[(lektion - 1) % 5],
              'start': START.isoformat(),
              'themenStart': (start_block if 'themaBlock' in z else d).isoformat(),
              'lektion': lektion})
    return {'art': 'LEKTIONSTAG', 'datum': d.isoformat(), 't': t,
            'probe': d.weekday() == 5, 'zyklus': z}


def heute_berlin():
    try:
        from zoneinfo import ZoneInfo
        return datetime.now(ZoneInfo('Europe/Berlin')).date()
    except Exception:
        return date.today()


def main():
    args = [a for a in sys.argv[1:] if a != '--json']
    d = _d(args[0]) if args else heute_berlin()
    s = status(d)
    if '--json' in sys.argv:
        print(json.dumps(s, ensure_ascii=False, indent=1))
        return
    if s['art'] == 'PAUSE':
        print('%s · PAUSE (%s bis %s) — nichts schreiben. Es geht am %s weiter.'
              % (s['datum'], s['von'], s['bis'], s['weiter']))
    elif s['art'] == 'UEBUNGSTAG':
        print('%s · UEBUNGSTAG (t = %d) — nichts schreiben.' % (s['datum'], s['t']))
    elif s['art'] == 'VORHER':
        print('%s · VORHER — die Etappe hat noch nicht begonnen.' % s['datum'])
    else:
        z = s['zyklus']
        print('%s · LEKTIONSTAG · Lektion %d%s (t = %d)'
              % (s['datum'], z['lektion'], ' + Probeprüfung (Samstag)' if s['probe'] else '', s['t']))
        print('zyklus = ' + json.dumps(z, ensure_ascii=False))
    print('Etappe endet am %s (%d Pausentage im Plan).'
          % (etappe_ende().isoformat(), pausentage_gesamt()))


if __name__ == '__main__':
    main()
