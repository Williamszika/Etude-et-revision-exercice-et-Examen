#!/usr/bin/env python3
"""Lektion VOLLSTÄNDIG und chat-fertig (Tabellen, Lösungen am Ende, Diktat verdeckt).
Aufruf: python3 coach/lektion_chat.py <Nr> [a|b]   a = Teil 1–2, b = Teil 3–4
Kontrolle auf stderr: jedes Feld des JSON muss benutzt sein, sonst wird es generisch angehängt."""
import json, sys, glob, os
LEK = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'deutsch-taeglich', 'lektionen')
USED, ANTW, OUT = set(), [], []
P = ''  # Präfix der Antwortnummern (A oder B)

def leaves(o, p=''):
    if isinstance(o, dict):
        for k, v in o.items(): yield from leaves(v, f'{p}.{k}' if p else k)
    elif isinstance(o, list):
        for i, v in enumerate(o): yield from leaves(v, f'{p}[{i}]')
    else: yield p

class N:
    """Wrapper: merkt sich, welche Felder gelesen wurden."""
    def __init__(s, o, p): s.o, s.p = o, p
    def __call__(s, k, d=''):
        v = s.o.get(k) if isinstance(s.o, dict) else None
        if v is None:
            if isinstance(s.o, dict) and k in s.o: USED.add(f'{s.p}.{k}')
            return d
        q = f'{s.p}.{k}'
        if isinstance(v, (dict, list)): return N(v, q)
        USED.add(q); return v
    def __iter__(s):
        for i, v in enumerate(s.o):
            q = f'{s.p}[{i}]'
            if isinstance(v, (dict, list)): yield N(v, q)
            else: USED.add(q); yield v
    def __bool__(s): return bool(s.o)
    def __len__(s): return len(s.o)
    def mark(s):
        for l in leaves(s.o, s.p): USED.add(l)

def w(*z): OUT.extend(z)
def ans(t):
    ANTW.append(t); return f'→ {P}{len(ANTW)}'
def tab(t):
    if not t: return
    h = list(t('head')); w('', '| ' + ' | '.join(map(str, h)) + ' |', '|' + '---|' * len(h))
    for r in t('rows'): w('| ' + ' | '.join(str(x) for x in r) + ' |')
    w('')
def bsp(b):
    for e in b or []:
        if isinstance(e, N): w(f'- {e("de")} — *{e("fr")}*')
        else: w(f'- {e}')
def test(t):
    if t: w(f'**Test:** {t("frage")} {ans(t("loesung"))}')
def fallen(fl):
    for i, f in enumerate(fl or [], 1):
        b = f('baustelle'); b = f' (Baustelle {b})' if b != '' else ''
        w(f'{i}. ~~{f("falsch")}~~ → **{f("richtig")}**{b} — {f("warum")}')

def karte(x, name):  # verb / wortschatz
    w(f'## {name} — {x("titel")}', f'**{x("uebersetzung")}** · {x("erklaerung")}', f'🇫🇷 {x("fr")}')
    tab(x('tabelle'))
    ch = x('chips')
    if ch: w('Merkpunkte: ' + ' · '.join(ch))
    bsp(x('beispiele'))
    if x('tipp'): w(f'Tipp: {x("tipp")}')
    test(x('test'))
    if x('sprechen'): w('🎙️ **Sprich laut:** ' + ' · '.join(x('sprechen')))
    if x('diskussion'): w(f'🎙️ **Diskussion:** {x("diskussion")}')

def vokabeln(v):
    w(f'## Vokabeln — {v("titel")} ({v("thema")})', v('fr'), '',
      '| # | Deutsch | Wortart | Français | Beispiel | Traduction |', '|---|---|---|---|---|---|')
    for i, x in enumerate(v('woerter'), 1):
        w(f'| {i} | {x("de")} | {x("wortart")} | {x("fr")} | {x("beispiel")} | {x("beispielFr")} |')
    a = v('aufgabe')
    if a: w('', f'✍️ **Aufgabe:** {a("frage")} *{a("hinweis")}* {ans(a("muster"))}')
    if v('tipp'): w(f'Tipp: {v("tipp")}')

def grammatik(g):
    w(f'## Grammatik — {g("titel")}', f'*{g("uebersetzung")}*', '', g('erklaerung'), f'🇫🇷 {g("fr")}')
    tab(g('tabelle'))
    ch = g('chips')
    if ch: w('Merkpunkte: ' + ' · '.join(ch))
    bsp(g('beispiele'))
    f = g('fehler')
    if f: w(f'**Typischer Fehler:** ~~{f("falsch")}~~ → **{f("richtig")}** — {f("warum")}')
    if g('tipp'): w(f'Tipp: {g("tipp")}')
    test(g('test'))
    if g('sprechen'): w('🎙️ **Sprich laut:** ' + ' · '.join(g('sprechen')))
    if g('diskussion'): w(f'🎙️ **Diskussion:** {g("diskussion")}')
    v = g('verstehen')
    if v:
        w('', '### Verstehen — Schritt für Schritt', f'**Wozu?** {v("warum")}')
        for s in v('schritte'):
            w('', f'**{s("titel")}** — {s("fr")}')
            if s('de'): w(s('de'))
            b = s('beispiele')
            if b: w(' · '.join(b))
        if v('franzoesisch'): w('', f'**Et en français ?** {v("franzoesisch")}')
        if v('fallen'): w('', '**Fallen:**'); fallen(v('fallen'))
        if v('merksatz'): w('', f'**Merksatz:** {v("merksatz")}')
        c = v('check')
        if c: w('', '**Check:** ' + ' · '.join(f'{i}. {x("frage")} ({ans(x("loesung"))[2:]})' for i, x in enumerate(c, 1)))

def kurzregel(k):
    w('## Kurzregel', f'🇫🇷 {k("fr")}', f'🇩🇪 {k("de")}'); bsp(k('beispiele'))

def deklination(d):
    w(f'## Deklination — {d("titel")} (Stufe {d("stufe")})', d('fr'))
    for i, s in enumerate(d('saetze'), 1):
        w('', f'**{i}.** {s("luecke")}',
          f'Bestimmer: {s("bestimmer")} · Fall: {s("fall")} · Genus: {s("genus")} · Artikel: {s("artikel")} · Endung: {s("adjektiv")}')
        if s('hinweis'): w(f'Hinweis: {s("hinweis")}')
        w(ans(s('loesung')))
    if d('tipp'): w(f'Tipp: {d("tipp")}')
    w('➕ **Extra Deklination (10 min)** — Frau Weber macht die nächste Etappe im Sprachmodus.')

def aufgabe_block(a, label):
    if a: w(f'**{label}:** {a("frage")} *{a("hinweis")}*' + (f' Anfang: „{a("platzhalter")}“' if a('platzhalter') else '') + f' {ans(a("muster"))}')

def lesen(l):
    w(f'## Lesen — {l("titel")}')
    if l('quelle'): w(f'Quelle: {l("quelle")}')
    w(l('fr'), '', l('text'), '', '❓ **Nach dem Lesen fragt Frau Weber, welche Wörter du nicht verstanden hast — und erklärt alle.**')
    h = l('hilfe')
    if h: w('', '**Hilfe:** ' + ' · '.join(h))
    r = l('redemittel')
    if r: w('**Damit fängst du an:** ' + ' · '.join(r))
    w(''); aufgabe_block(l('nacherzaehlen'), 'Schritt 1 — Nacherzählen'); aufgabe_block(l('hauptaussage'), 'Schritt 2 — Hauptaussage')
    fr = l('fragen')
    if fr:
        w('', '**Schritt 3 — Fragen:**')
        for i, f in enumerate(fr, 1): w(f'{i}. **{f("operator")}**: {f("frage")} *{f("hinweis")}* {ans(f("loesung"))}')
    ws = l('wortschatz')
    if ws:
        w('', f'**Schritt 4 — Wortschatz aus dem Text** ({ws("einleitung")})', '', '| Wort | Niveau | Français | Im Text |', '|---|---|---|---|')
        for x in ws('woerter'): w(f'| {x("wort")} | {x("niveau")} | {x("fr")} | {x("imText")} |')
        a = ws('aufgabe')
        if a: w('', f'✍️ {a("frage")} *{a("hinweis")}* {ans(a("muster"))}')
    gr = l('grammatik')
    if gr:
        w('', f'**Schritt 5 — Grammatik im Text** ({gr("einleitung")})')
        for i, p in enumerate(gr('punkte'), 1):
            w(f'{i}. **{p("name")}** — {p("regel")} Im Text: „{p("imText")}“ Aufgabe: {p("aufgabe")}' + (f' *{p("hinweis")}*' if p('hinweis') else '') + f' {ans(p("loesung"))}')
    ko = l('konnektoren')
    if ko:
        w('', f'**Schritt 6 — Konnektoren** ({ko("einleitung")})')
        for i, k in enumerate(ko('aufgaben'), 1):
            w(f'{i}. [{k("typ")}] „{k("satz")}“ — {k("frage")} *{k("hinweis")}* {ans(k("loesung"))}')
    w(''); aufgabe_block(l('erklaeren'), 'Schritt 7 — Erklären (30 Sekunden laut)')
    if l('tipp'): w(f'Tipp: {l("tipp")}')

def aufgabenblock(t, name):
    w(f'## {name} — {t("titel")}')
    for k in ('badge', 'ziel', 'fr', 'pruefungsziel', 'dauer', 'punkte'):
        if t(k) != '': w(f'{k}: {t(k)}' if k in ('dauer', 'punkte') else t(k))
    te = t('teile')
    if te: w('Teile: ' + ', '.join(te))
    if t('text'): w('', t('text'), '')
    for i, a in enumerate(t('aufgaben'), 1):
        o = a('optionen'); o = ' — ' + ' / '.join(f'{chr(97+j)}) {x}' for j, x in enumerate(o)) if o else ''
        w(f'{i}. [{a("typ")}] {a("frage")}{o}' + (f' *{a("hinweis")}*' if a('hinweis') else '') + f' {ans(a("loesung"))}')
    dl = t('dialog')
    if dl:
        w('', f'**Dialog** — {dl("situation")}')
        for z in dl('zeilen'): w(f'- **{z("wer")}:** {z("satz")}' + (f' *({z("hinweis")})*' if z('hinweis') else ''))
    al = t('alltag')
    if al: w('', '**Im Alltag heute:**'); [w(f'- {x}') for x in al]
    if t('phase') or t('thema'): w(f'*{t("phase")} · {t("thema")}*')
    if t('tipp'): w(f'Tipp: {t("tipp")}')

def leben(l):
    w(f'## Im Leben — {l("wo")}: {l("titel")}', l('fr'), f'**Situation:** {l("situation")}', f'**Warum:** {l("warum")}', '',
      '**Du sagst:**'); [w(f'- {x("de")} — *{x("fr")}*') for x in l('dusagst')]
    w('**Du hörst:**'); [w(f'- {x("de")} — *{x("fr")}*') for x in l('duhoerst')]
    r = l('rettung')
    if r: w('**Rettungssätze:** ' + ' · '.join(r))
    if l('fallen'): w('**Fallen:**'); fallen(l('fallen'))
    if l('heute'): w(f'**Heute im echten Leben:** {l("heute")}')

def aussprache(a):
    w('## Aussprache'); x = a.o
    for k in a.o:
        v = a(k)
        if k == 'satz': w(f'**„{v}“**')
        elif isinstance(v, N): w('Übung: ' + ' · '.join(str(x) for x in v))
        else: w(f'{k}: {v}')

def diktat(d):
    w(f'## Diktat — {d("titel")}', '*(Frau Weber liest zweimal, langsam, Satz für Satz. Du schreibst im Chat; dann Korrektur.)*', '',
      '<details><summary>Text (erst nach dem Schreiben öffnen)</summary>', '', d('text'), '', '</details>')
    h = d('hilfe')
    if h: w('**Hilfe:** ' + ' · '.join(h))
    fa = d('fallen')
    if fa: w('**Achtung beim Schreiben (nach dem Diktat lesen):** ' + ' · '.join(fa))
    for k in d.o:
        if k not in ('titel', 'text', 'hilfe', 'fallen'): w(f'{k}: {d(k)}')

def uebersetzung(u):
    w(f'## {u("titel","Übersetzung FR → DE")}')
    loes = []
    for i, s in enumerate(u('saetze'), 1):
        if isinstance(s, N):
            w(f'{i}. {s("fr")}' + (f' *({s("hinweis")})*' if s('hinweis') else '')); loes.append(f'{i}. {s("de")}')
        else: w(f'{i}. {s}')
    if loes: w(ans(' · '.join(loes)))

R = {'verb': lambda x: karte(x, 'Verb des Tages'), 'wortschatz': lambda x: karte(x, 'Wort des Tages'), 'vokabeln': vokabeln,
     'grammatik': grammatik, 'kurzregel': kurzregel, 'deklination': deklination, 'lesen': lesen,
     'training': lambda x: aufgabenblock(x, 'Training'), 'leben': leben, 'telc': lambda x: aufgabenblock(x, 'Fertigkeit des Tages'),
     'probe': lambda x: aufgabenblock(x, 'Probeprüfung'), 'aussprache': aussprache, 'diktat': diktat, 'uebersetzung': uebersetzung}
NAMEN = {'verb':'Verb des Tages','wortschatz':'Wort des Tages','grammatik':'Grammatik','training':'Training','lesen':'Lesen','leben':'Im Leben','telc':'Fertigkeit'}
ORD = ['verb', 'wortschatz', 'vokabeln', 'grammatik', 'kurzregel', 'deklination', 'lesen', 'training', 'leben', 'telc', 'probe', 'aussprache', 'diktat', 'uebersetzung']
A = set(ORD[:6])

def main():
    global P
    nr = int(sys.argv[1]); teil = sys.argv[2] if len(sys.argv) > 2 else ''
    for f in sorted(glob.glob(os.path.join(LEK, '*.json'))):
        d = json.load(open(f))
        if d.get('zyklus', {}).get('lektion') == nr: break
    else: sys.exit(f'Lektion {nr} gibt es (noch) nicht.')
    keys = [k for k in ORD if k in d] + [k for k in d if k not in ORD and k not in ('datum', 'thema', 'zyklus')]
    if teil == 'a': keys = [k for k in keys if k in A]; P = 'A'
    if teil == 'b': keys = [k for k in keys if k not in A]; P = 'B'
    z = d['zyklus']
    w(f'# Lektion {nr} — {d.get("thema","")} ({d["datum"]})',
      f'Grammatik: {z.get("grammatik")} · Thema-Tag {z.get("themenTag")} von {z.get("themenTage",3)} · Fokus: {z.get("fokus")}')
    for k in keys:
        w('', '---')
        n = N(d[k], k)
        (R.get(k) or (lambda x: (w(f'## {k}'), w(json.dumps(x.o, ensure_ascii=False, indent=1)), x.mark())))(n)
    alle = [l for k in keys for l in leaves(d[k], k)]
    fehlt = [l for l in alle if l not in USED]
    if fehlt:  # nichts verlieren: Rest lesbar anhängen, pro Block und Unterfeld
        def gen(o, tiefe):
            if isinstance(o, dict):
                for k2, v2 in o.items():
                    if k2 in ('loesung', 'muster'): w(ans(v2)); continue
                    if isinstance(v2, (dict, list)): w(f'{"  "*tiefe}- **{k2}:**'); gen(v2, tiefe + 1)
                    else: w(f'{"  "*tiefe}- **{k2}:** {v2}')
            elif isinstance(o, list):
                for i2, v2 in enumerate(o, 1):
                    if isinstance(v2, (dict, list)): w(f'{"  "*tiefe}{i2}.'); gen(v2, tiefe + 1)
                    else: w(f'{"  "*tiefe}{i2}. {v2}')
            else: w(f'{"  "*tiefe}{o}')
        gesehen = set()
        for l in fehlt:
            teile = l.replace(']', '').replace('[', '.').split('.')
            kopf = '.'.join(teile[:2])
            if kopf in gesehen: continue
            gesehen.add(kopf)
            v = d[teile[0]][int(teile[1])] if teile[1].isdigit() else d[teile[0]][teile[1]]
            w('', f'### {NAMEN.get(teile[0], teile[0])} — {teile[1]}')
            gen(v, 0)
    w('', '---', f'<details><summary><b>Réponses ({P or "alle"})</b></summary>', '')
    w(*[f'{P}{i}. {t}' for i, t in enumerate(ANTW, 1)])
    w('', '</details>')
    print('\n'.join(str(x) for x in OUT))
    print(f'Kontrolle: {len(alle)} Felder, nicht formatiert (generisch angehängt): {len(fehlt)} {fehlt[:8]}', file=sys.stderr)

main()
