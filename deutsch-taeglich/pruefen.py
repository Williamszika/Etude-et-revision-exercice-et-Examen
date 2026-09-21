#!/usr/bin/env python3
"""Nachweisen statt annehmen — liegt die heutige Lektion wirklich im Repo UND auf der Seite?

Ihre Anweisung vom 21.09.2026:

    « il faut toujours la publier dans le dépôt et verifier si elle as été publier »

Der Hintergrund: Die 5:30-Routine hat neunmal eine Lektion veröffentlicht und nie
committet (31.08., 01.09., 02.–04.09., 05.09., 07.09., 09.09., 10.09., 21.09.).
Jedes Mal lag sie nur im Artifact und wäre beim nächsten Build verschwunden.
Am 21.09. kam der umgekehrte Fall dazu: Weil niemand nachgesehen hatte, entstand
eine zweite Lektion für denselben Tag.

Dieses Skript beantwortet beide Fragen mit einem Exitcode, nicht mit einem Gefühl.

    python3 deutsch-taeglich/pruefen.py                      # nur Repo-Seite
    python3 deutsch-taeglich/pruefen.py <artifact.html>      # Repo UND Seite

Das HTML ist die Datei, die `Artifact action:"read"` auf
e499dbe3-e198-410a-94d3-9393e6b27c84 abgelegt hat.

Exitcode 0 = alles nachgewiesen. Alles andere = etwas fehlt, und es steht dabei, was.
"""
import json
import os
import subprocess
import sys
from datetime import date

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LEK = os.path.join(REPO, 'deutsch-taeglich', 'lektionen')
START = date(2026, 9, 11)

ok, fehler = [], []


def sagt(gut, text):
    (ok if gut else fehler).append(text)
    print(('  OK   ' if gut else '  FEHLT ') + text)


def git(*args):
    r = subprocess.run(['git', '-C', REPO] + list(args),
                       capture_output=True, text=True)
    return r.returncode, r.stdout.strip(), r.stderr.strip()


def heute_ist_lektionstag(heute):
    t = (heute - START).days
    return t >= 0 and t % 2 == 0, t


def pruefe_repo(datum):
    """1-4: Die Lektion liegt im Arbeitsbaum, ist committet und ist gepusht."""
    pfad = os.path.join(LEK, datum + '.json')
    rel = os.path.relpath(pfad, REPO)

    da = os.path.isfile(pfad)
    sagt(da, 'Datei im Arbeitsbaum: ' + rel)
    if not da:
        return None

    lektion = json.load(open(pfad, encoding='utf-8'))

    code, _, _ = git('ls-files', '--error-unmatch', rel)
    sagt(code == 0, 'von git verfolgt (nicht nur auf der Platte)')

    code, aus, _ = git('status', '--porcelain', '--', rel)
    sagt(code == 0 and aus == '', 'committet — keine uncommitteten Änderungen')

    code, zweig, _ = git('rev-parse', '--abbrev-ref', 'HEAD')
    code2, lokal, _ = git('rev-parse', 'HEAD')
    code3, fern, _ = git('rev-parse', 'origin/' + zweig)
    sagt(code3 == 0 and lokal == fern,
         'gepusht — origin/%s steht auf demselben Commit' % zweig)

    # Der Inhalt im letzten Commit muss dem auf der Platte entsprechen.
    code, im_commit, _ = git('show', 'HEAD:' + rel)
    gleich = code == 0 and json.loads(im_commit) == lektion
    sagt(gleich, 'Inhalt im Commit ist derselbe wie auf der Platte')

    return lektion


def lektionen_aus_html(pfad):
    """Holt das Array `const LEKTIONEN = [...]` aus der veröffentlichten Seite."""
    s = open(pfad, encoding='utf-8').read()
    marke = 'const LEKTIONEN = '
    if marke not in s:
        return None
    arr, _ = json.JSONDecoder().raw_decode(s[s.index(marke) + len(marke):])
    return arr


def pruefe_seite(html, datum, lektion):
    """5-7: Die Seite trägt denselben Tag mit demselben Inhalt."""
    da = os.path.isfile(html)
    sagt(da, 'Artifact-HTML gelesen: ' + os.path.basename(html))
    if not da:
        return

    arr = lektionen_aus_html(html)
    sagt(arr is not None, 'LEKTIONEN im HTML gefunden')
    if arr is None:
        return

    treffer = [l for l in arr if l.get('datum') == datum]
    sagt(bool(treffer), 'Lektion vom %s steht auf der veröffentlichten Seite' % datum)
    if not treffer:
        print('         auf der Seite stehen: ' +
              ', '.join(l.get('datum', '?') for l in arr))
        return

    if lektion is None:
        return

    if treffer[0] == lektion:
        sagt(True, 'Seite und Repo sind Wort für Wort identisch')
    else:
        sagt(False, 'Seite und Repo weichen voneinander ab')
        for feld in sorted(set(treffer[0]) | set(lektion)):
            if treffer[0].get(feld) != lektion.get(feld):
                print('         unterschiedlich im Block: ' + feld)


def main():
    heute = date.today()
    datum = heute.isoformat()
    lektionstag, t = heute_ist_lektionstag(heute)

    print('Heute: %s · t = (heute − 2026-09-11) = %d → %s'
          % (datum, t, 'LEKTIONSTAG' if lektionstag else 'Übungstag'))

    if not lektionstag:
        print('\nÜbungstag: Es entsteht keine Datei in lektionen/. Die Vorlage baut den')
        print('Übungstag aus dem leeren Tag von selbst. Nichts nachzuweisen.')
        return 0

    print('\nIm Repo:')
    lektion = pruefe_repo(datum)

    if len(sys.argv) > 1:
        print('\nAuf der veröffentlichten Seite:')
        pruefe_seite(sys.argv[1], datum, lektion)
    else:
        print('\nAuf der veröffentlichten Seite: nicht geprüft.')
        print('  Dafür erst `Artifact action:"read"` auf')
        print('  e499dbe3-e198-410a-94d3-9393e6b27c84 und die gespeicherte')
        print('  HTML-Datei diesem Skript als Argument mitgeben.')

    print()
    if fehler:
        print('NICHT FERTIG — %d von %d Nachweisen fehlen:' % (len(fehler), len(ok) + len(fehler)))
        for f in fehler:
            print('  · ' + f)
        return 1

    print('Alle %d Nachweise erbracht.' % len(ok))
    return 0


if __name__ == '__main__':
    sys.exit(main())
