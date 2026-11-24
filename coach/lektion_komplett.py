#!/usr/bin/env python3
"""Gibt eine Lektion VOLLSTÄNDIG als Markdown aus (für den Chat / Sprachmodus).
Aufruf: python3 coach/lektion_komplett.py <Lektionsnummer> [a|b]  (a = Teil 1–2, b = Teil 3–4)
Jedes Feld des JSON wird ausgegeben; Lösungen/Muster kommen ans Ende (<details>)."""
import json, sys, glob, os
HIER = os.path.dirname(os.path.abspath(__file__))
LEK = os.path.join(HIER, '..', 'deutsch-taeglich', 'lektionen')
LOES = {'loesung', 'muster', 'richtig_loesung'}
NAMEN = {'verb': 'Verb des Tages', 'wortschatz': 'Wort des Tages', 'vokabeln': 'Vokabeln',
 'grammatik': 'Grammatik', 'kurzregel': 'Kurzregel', 'deklination': 'Deklination — die Kette',
 'lesen': 'Lesen (Schritt 1–7)', 'training': 'Training', 'leben': 'Im Leben',
 'telc': 'Fertigkeit des Tages', 'probe': 'Probeprüfung', 'aussprache': 'Aussprache',
 'diktat': 'Diktat', 'uebersetzung': 'Übersetzung FR → DE', 'missionen': 'Missionen'}
SKIP = {'datum', 'thema', 'zyklus'}
antworten, gesehen = [], []

def finde(nr):
    for f in sorted(glob.glob(os.path.join(LEK, '*.json'))):
        d = json.load(open(f))
        if d.get('zyklus', {}).get('lektion') == nr:
            return f, d
    sys.exit(f'Lektion {nr} gibt es (noch) nicht.')

def zelle(v):
    return str(v).replace('\n', ' ').replace('|', '/')

def render(o, pfad, out, tiefe):
    if isinstance(o, dict):
        if set(o) >= {'head', 'rows'}:
            out.append('| ' + ' | '.join(map(zelle, o['head'])) + ' |')
            out.append('|' + '---|' * len(o['head']))
            for r in o['rows']:
                out.append('| ' + ' | '.join(map(zelle, r)) + ' |')
            gesehen.append(pfad); return
        for k, v in o.items():
            p = f'{pfad}.{k}'
            if k in LOES:
                antworten.append(f'- **{pfad}** → {v if not isinstance(v,(dict,list)) else json.dumps(v,ensure_ascii=False)}')
                out.append(f'*({k}: siehe Antworten {len(antworten)})*'); gesehen.append(p); continue
            if isinstance(v, (dict, list)):
                out.append(f'\n{"#"*min(tiefe+3,6)} {k}')
                render(v, p, out, tiefe + 1)
            else:
                out.append(f'- **{k}:** {v}' if k not in ('text',) else f'**{k}:**\n\n{v}\n')
                gesehen.append(p)
    elif isinstance(o, list):
        for i, v in enumerate(o, 1):
            if isinstance(v, (dict, list)):
                out.append(f'\n**{i}.**')
                render(v, f'{pfad}[{i}]', out, tiefe + 1)
            else:
                out.append(f'{i}. {v}'); gesehen.append(f'{pfad}[{i}]')
    else:
        out.append(str(o)); gesehen.append(pfad)

def main():
    nr = int(sys.argv[1]); f, d = finde(nr)
    z = d['zyklus']
    out = [f'# Lektion {nr} — {d.get("thema","")} ({d["datum"]})',
           f'Grammatik: {z.get("grammatik")} · Thema-Tag {z.get("themenTag")} von {z.get("themenTage",3)} · Fokus: {z.get("fokus")} · Datei `{os.path.basename(f)}`']
    ORDNUNG = ['verb','wortschatz','vokabeln','grammatik','kurzregel','deklination','lesen','training',
               'leben','telc','probe','aussprache','diktat','uebersetzung']
    keys = [k for k in ORDNUNG if k in d] + [k for k in d if k not in ORDNUNG and k not in SKIP]
    teil = sys.argv[2] if len(sys.argv) > 2 else ''
    A = {'verb','wortschatz','vokabeln','grammatik','kurzregel','deklination'}
    if teil == 'a': keys = [k for k in keys if k in A]
    if teil == 'b': keys = [k for k in keys if k not in A]
    for k in keys:
        v = d[k]
        out.append(f'\n---\n## {NAMEN.get(k, k)}')
        render(v, k, out, 0)
    out.append('\n---\n<details><summary><b>Antworten</b></summary>\n')
    out += [f'{i}. ' + a[2:] for i, a in enumerate(antworten, 1)]
    out.append('\n</details>')
    print('\n'.join(out))
    # Kontrolle: jede Blattstelle des JSON wurde ausgegeben
    def blaetter(o, p):
        if isinstance(o, dict):
            if set(o) >= {'head','rows'}: yield p; return
            for k, v in o.items(): yield from blaetter(v, f'{p}.{k}' if p else k)
        elif isinstance(o, list):
            for i, v in enumerate(o, 1): yield from blaetter(v, f'{p}[{i}]')
        else: yield p
    alle = [b for b in blaetter({k: d[k] for k in keys}, '')]
    fehlt = [b for b in alle if b not in set(gesehen)]
    print(f'\n<!-- Kontrolle: {len(alle)} Felder, fehlend: {len(fehlt)} {fehlt[:5]} -->', file=sys.stderr)

main()
