#!/usr/bin/env python3
"""Was ist heute bei Deutsch täglich? — die einzige Stelle, an der das gerechnet wird.

    python3 deutsch-taeglich/heute.py              # heute (Europe/Berlin)
    python3 deutsch-taeglich/heute.py 2026-10-20   # ein beliebiges Datum
    python3 deutsch-taeglich/heute.py --json       # dasselbe als JSON
    python3 deutsch-taeglich/heute.py --plan       # alle Lektionstage mit Thema

Antwort ist eine von vier Arten:

    PAUSE        — nichts schreiben (Pausen stehen in pausen.json)
    UEBUNGSTAG   — nichts schreiben (sonntags: Ruhetag mit Wochenrückblick, `ruhetag: true`)
    LEKTIONSTAG  — Lektion schreiben; die Zeile nennt alle zyklus-Felder
    VORHER       — vor dem Start der Etappe

**Neustart am 16.10.2026** (ihr Wunsch vom 15.10.2026: von null anfangen, 75 Minuten am Tag,
sechs Tage die Woche). **Seit dem 15.10.2026 abends: das ganze B1-Programm zweimal** (ihre
Wahl „on fait le B“: zwei volle Durchgänge, je drei Lektionen pro Thema). Die Regel:

    Lektionstag  = jeder Tag ab 16.10.2026 außer Sonntag und außer Pausentagen
    lektion      = Zahl der Lektionstage vom 16.10. bis heute (1, 2, 3 …)
    durchgang    = 1 für Lektion 1–87 (Kurs B1.1), 2 für Lektion 88–174 (Kurs B1.2)
    themaBlock   = ((lektion − 1) // 3) % 29 + 1 — drei Lektionen pro Grammatikthema (1 … 29)
    themenTag    = (lektion − 1) %  3 + 1        — 1 entdecken · 2 üben · 3 anwenden
    ab Lektion 175: Wiederholung bis zum Ende (20.05.2027 = Lektion 186, ohne Pausen)

Pausentage zählen nicht mit: Der Plan rückt nach hinten, keine Lektion fällt aus. Die
Routinen, build.py und pruefen.py fragen hier nach, statt selbst zu rechnen.
"""
import json
import os
import sys
from datetime import date, datetime, timedelta

BASE = os.path.dirname(os.path.abspath(__file__))
START = date(2026, 10, 16)
PLAN_ENDE = date(2027, 5, 20)        # Ende der Etappe ohne Pausen (Lektion 186)
RUHETAG = 6                          # Sonntag (Python weekday); in JS getDay() = 0
PRO_THEMA = 3                        # Lektionen pro Grammatikthema
THEMEN_GESAMT = 29
DURCHGAENGE = 2                      # das ganze B1-Programm zweimal
GRAMMATIK_LEKTIONEN = THEMEN_GESAMT * PRO_THEMA * DURCHGAENGE   # 174
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


def _roh():
    pfad = os.path.join(BASE, 'pausen.json')
    if not os.path.exists(pfad):
        return []
    return json.load(open(pfad, encoding='utf-8')).get('pausen', [])


def pausen():
    """Alle Pausen als (von, bis, grund), beide Tage eingeschlossen — auch die,
    die im Plan mitzählen (siehe zaehlende_pausen)."""
    return [(_d(p['von']), _d(p['bis']), p.get('grund', '')) for p in _roh()]


def verschiebende_pausen():
    """Nur die Pausen, die den Plan nach hinten schieben.

    Eine Pause mit `"zaehlt": true` ist zwar ein Pausentag (keine Lektion, kein
    Übungstag), läuft im Plan aber mit — so fällt nur ein Übungstag weg, nie eine
    Lektion. Eingeführt am 05.10.2026 für den 19.10.: sie wollte am 20.10. mit
    Lektion 13 neu anfangen, ohne Übungstag davor."""
    return [(_d(p['von']), _d(p['bis']), p.get('grund', ''))
            for p in _roh() if not p.get('zaehlt')]


def in_pause(d):
    for von, bis, _ in pausen():
        if von <= d <= bis:
            return (von, bis)
    return None


def ist_lektionstag(d):
    return d >= START and d.weekday() != RUHETAG and not in_pause(d)


def lektion_von(d):
    """Zahl der Lektionstage vom Start bis einschließlich d."""
    if d < START:
        return 0
    n, x = 0, START
    while x <= d:
        if ist_lektionstag(x):
            n += 1
        x += timedelta(days=1)
    return n


def _lektionstage_ohne_pausen(bis):
    n, x = 0, START
    while x <= bis:
        if x.weekday() != RUHETAG:
            n += 1
        x += timedelta(days=1)
    return n


LEKTIONEN_GESAMT = _lektionstage_ohne_pausen(PLAN_ENDE)


def datum_von_lektion(n):
    """Der Kalendertag der n-ten Lektion (mit Pausen)."""
    x, k = START, 0
    while True:
        if ist_lektionstag(x):
            k += 1
            if k == n:
                return x
        x += timedelta(days=1)


def etappe_ende():
    return datum_von_lektion(LEKTIONEN_GESAMT)


def pausentage_gesamt():
    return sum((bis - von).days + 1 for von, bis, _ in verschiebende_pausen() if bis >= START)


def effektiver_start(d):
    """Für die Seite und die App: der Start der Etappe (kein Verschieben mehr nötig)."""
    return START


def probe_am(d):
    """Probeprüfung jeden zweiten Samstag, erstmals am 24.10.2026."""
    erste = date(2026, 10, 24)
    return d.weekday() == 5 and d >= erste and ((d - erste).days // 7) % 2 == 0


def status(d):
    p = in_pause(d)
    if p:
        nach = p[1] + timedelta(days=1)
        while in_pause(nach) or nach.weekday() == RUHETAG:
            nach += timedelta(days=1)
        return {'art': 'PAUSE', 'datum': d.isoformat(), 'von': p[0].isoformat(),
                'bis': p[1].isoformat(), 'weiter': nach.isoformat()}
    if d < START:
        return {'art': 'VORHER', 'datum': d.isoformat(), 'start': START.isoformat()}
    if d.weekday() == RUHETAG:
        return {'art': 'UEBUNGSTAG', 'datum': d.isoformat(), 'ruhetag': True,
                'lektionVorher': lektion_von(d)}
    lektion = lektion_von(d)
    z = {'woche': (d - START).days // 7 + 1, 'gesamt': THEMEN_GESAMT, 'etappe': 'B1',
         'takt': 1, 'ruhetag': 0, 'themenTage': PRO_THEMA}
    if lektion > GRAMMATIK_LEKTIONEN:
        z['phase'] = 'Wiederholung'
        themen_start = d
    else:
        block = ((lektion - 1) // PRO_THEMA) % THEMEN_GESAMT + 1
        themen_tag = (lektion - 1) % PRO_THEMA + 1
        z['durchgang'] = (lektion - 1) // (THEMEN_GESAMT * PRO_THEMA) + 1
        # Wortfeld läuft über beide Durchgänge weiter: dieselbe Grammatik kommt im
        # zweiten Durchgang in einem anderen Lebensbereich wieder (Block 1 → Thema 14 …).
        feld = (block - 1 + THEMEN_GESAMT * (z['durchgang'] - 1)) % 16
        z.update({'thema': THEMEN[feld], 'themaNr': feld + 1,
                  'grammatik': GRAMMATIK[block - 1], 'grammatikNr': block,
                  'themaBlock': block, 'themenTag': themen_tag})
        themen_start = datum_von_lektion(lektion - themen_tag + 1)
    z.update({'tag': WOCHENTAGE[d.weekday()], 'fokus': REIHE[(lektion - 1) % 5],
              'start': START.isoformat(), 'themenStart': themen_start.isoformat(),
              'lektion': lektion})
    return {'art': 'LEKTIONSTAG', 'datum': d.isoformat(), 'probe': probe_am(d), 'zyklus': z}


def heute_berlin():
    try:
        from zoneinfo import ZoneInfo
        return datetime.now(ZoneInfo('Europe/Berlin')).date()
    except Exception:
        return date.today()


def plan():
    """Alle Lektionstage der Etappe mit Grammatikthema — für die Planseite."""
    out = []
    for n in range(1, LEKTIONEN_GESAMT + 1):
        d = datum_von_lektion(n)
        out.append((n, d, status(d)['zyklus']))
    return out


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    if '--plan' in sys.argv:
        for n, d, z in plan():
            print('%3d  %s %s  %s' % (n, d.isoformat(), WOCHENTAGE[d.weekday()][:2],
                  z.get('phase') or 'D%d G%d/%d %s' % (z['durchgang'], z['grammatikNr'], z['themenTag'], z['grammatik'])))
        return
    d = _d(args[0]) if args else heute_berlin()
    s = status(d)
    if '--json' in sys.argv:
        print(json.dumps(s, ensure_ascii=False, indent=1))
        return
    if s['art'] == 'PAUSE':
        print('%s · PAUSE (%s bis %s) — nichts schreiben. Es geht am %s weiter.'
              % (s['datum'], s['von'], s['bis'], s['weiter']))
    elif s['art'] == 'UEBUNGSTAG':
        print('%s · UEBUNGSTAG%s — nichts schreiben.'
              % (s['datum'], ' (Sonntag: Ruhetag mit Wochenrückblick)' if s.get('ruhetag') else ''))
    elif s['art'] == 'VORHER':
        print('%s · VORHER — die Etappe beginnt am %s.' % (s['datum'], s['start']))
    else:
        z = s['zyklus']
        print('%s · LEKTIONSTAG · Lektion %d von %d%s'
              % (s['datum'], z['lektion'], LEKTIONEN_GESAMT,
                 ' + Probeprüfung (Samstag)' if s['probe'] else ''))
        print('zyklus = ' + json.dumps(z, ensure_ascii=False))
    print('Etappe: %s bis %s · %d Lektionen (%d Pausentage im Plan).'
          % (START.isoformat(), etappe_ende().isoformat(), LEKTIONEN_GESAMT, pausentage_gesamt()))


if __name__ == '__main__':
    main()
