#!/usr/bin/env python3
"""Setzt für jeden Artikel aus krankheiten/artikel/<id>.html einen PLATZHALTER hinter den Schlaganfall in
krankheiten/index.html (seit 07.11.2026): Kopf, Kapitelüberschriften und Prüfungsfragen — der ganze Artikel wird
erst geladen, wenn sie ihn öffnet (fetch artikel/<id>.html). So bleibt die Seite unter 16 MB, auch mit 52 Artikeln.
Beim Veröffentlichen die Dateien mitschicken: files {"artikel/<id>.html": "krankheiten/artikel/<id>.html"}.
Wiederholbar: alles zwischen den Markierungen ARTIKEL-START/ENDE wird jedes Mal neu geschrieben,
und die Einträge der Bibliothek werden für jeden vorhandenen Artikel auf „jetzt lesen“ gesetzt.
    python3 krankheiten/artikel_einsetzen.py && python3 bibliothek/build.py
"""
import os, re
BASE = os.path.dirname(os.path.abspath(__file__))
F = os.path.join(BASE, "index.html")
REIHE = [("diabetes", "Diabetes mellitus Typ 1 und Typ 2"), ("asthma", "Asthma bronchiale"),
         ("ms", "Multiple Sklerose"), ("hypertonie", "Hypertonie"),
         ("depression", "Depression"), ("myokardinfarkt", "Myokard&shy;infarkt"),
         ("herzinsuffizienz", "Herz&shy;insuffizienz"), ("thrombose", "Thrombose"),
         ("schizophrenie", "Schizophrenie"),
         ("demenz", "Demenz"),
         ("pneumonie", "Pneumonie"),
         ("mangelernaehrung", "Mangel&shy;ernährung"),
         ("frakturen", "Frakturen"),
         ("epilepsie", "Epilepsie"),
         ("delir", "Delir"),
         ("lungenembolie", "Lungen&shy;embolie"),
         ("parkinson", "Parkinson"),
         ("arthrose", "Arthrose"),
         ("angststoerungen", "Angst&shy;störungen"),
         ("osteoporose", "Osteoporose"),
         ("zwangsstoerungen", "Zwangs&shy;störungen")]
s = open(F, encoding="utf-8").read()
A, E = "<!-- ARTIKEL-START -->", "<!-- ARTIKEL-ENDE -->"
if A in s:
    i, j = s.index(A), s.index(E) + len(E)
    s = s[:i] + s[j:]
da = [(i, t) for i, t in REIHE if os.path.exists(os.path.join(BASE, "artikel", i + ".html"))]
teile = [A]
def platzhalter(i, t):
    kopf = t[t.index('<div class="wrap artkopf">'):t.index('<nav class="inhalt"')].rstrip()
    kap = re.findall(r'<section class="kap" id="(' + re.escape(i) + r'-k\d+)" data-kap="(\d+)">\s*(<h3>.*?</h3>)', t, re.S)
    assert len(kap) == 16, (i, len(kap))
    fr = re.findall(r'<details class="frage".*?</details>', t, re.S)
    assert all(f.count('<details') == 1 for f in fr), i
    out = [f'<article id="{i}" data-laden="{i}.html">', '  ' + kopf.strip(), '  <div class="wrap">']
    out += [f'  <section class="kap" id="{k}" data-kap="{n}">{h}</section>' for k, n, h in kap]
    out += ['  <div class="nur-fragen" hidden>'] + ['  ' + f for f in fr] + ['  </div>', '  </div>', '</article>']
    return "\n".join(out), len(fr)
for n, (i, _) in enumerate(da, start=2):
    p = os.path.join(BASE, "artikel", i + ".html")
    t = open(p, encoding="utf-8").read().strip()
    t2 = re.sub(r'(<span class="nr">)Artikel \d+', r'\g<1>Artikel ' + str(n), t, count=1)
    if t2 != t: open(p, "w", encoding="utf-8").write(t2 + "\n")
    ph, nf = platzhalter(i, t2)
    teile.append(ph)
    print(f"  {i}: Platzhalter {len(ph)//1024} KB, {nf} Fragen (Artikel {len(t2)//1024} KB)")
teile.append(E)
k = s.index("</article>", s.index('<article id="schlaganfall">')) + len("</article>")
s = s[:k] + "\n\n" + "\n\n".join(teile) + s[k:]
# Bibliothek: geplant -> jetzt lesen
for n, (i, titel) in enumerate(da, start=2):
    alt = re.compile(r'<(?:div|a) class="buch[^"]*"[^>]*><span class="st">[^<]*</span><b>' + re.escape(titel) + r'</b>(<span class="woher">[^<]*</span>)</(?:div|a)>')
    s, c = alt.subn(lambda m: f'<a class="buch fertig" href="#{i}"><span class="st">Artikel {n} · jetzt lesen ↓</span><b>{titel}</b>{m.group(1)}</a>', s)
    if not c: print("  ! Bibliothekseintrag nicht gefunden:", titel)
zahl = 1 + len(da)
s = re.sub(r'<p class="kicker">Artikel 1 · Der Schlaganfall · 52 Krankheiten in der Bibliothek</p>|<p class="kicker">\d+ Artikel · 52 Krankheiten in der Bibliothek</p>',
           f'<p class="kicker">{zahl} Artikel · 52 Krankheiten in der Bibliothek</p>', s)
s = re.sub(r'<p><strong>Krankheiten verstehen</strong> · [^<]*?· 52 Krankheiten',
           '<p><strong>Krankheiten verstehen</strong> · ' + str(zahl) + ' Artikel: Schlaganfall' + ''.join(', ' + t.split(' Typ')[0].replace('&shy;', '') for _, t in da) + ' · 52 Krankheiten', s)
open(F, "w", encoding="utf-8").write(s)
print("OK  Artikel im Buch:", ["schlaganfall"] + [i for i, _ in da])
