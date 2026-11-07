#!/usr/bin/env python3
"""Setzt die Artikel aus krankheiten/artikel/<id>.html hinter den Schlaganfall in krankheiten/index.html.
Wiederholbar: alles zwischen den Markierungen ARTIKEL-START/ENDE wird jedes Mal neu geschrieben,
und die Einträge der Bibliothek werden für jeden vorhandenen Artikel auf „jetzt lesen“ gesetzt.
    python3 krankheiten/artikel_einsetzen.py && python3 bibliothek/build.py
"""
import os, re
BASE = os.path.dirname(os.path.abspath(__file__))
F = os.path.join(BASE, "index.html")
REIHE = [("diabetes", "Diabetes mellitus Typ 1 und Typ 2"), ("asthma", "Asthma bronchiale"),
         ("ms", "Multiple Sklerose"), ("hypertonie", "Hypertonie")]
s = open(F, encoding="utf-8").read()
A, E = "<!-- ARTIKEL-START -->", "<!-- ARTIKEL-ENDE -->"
if A in s:
    i, j = s.index(A), s.index(E) + len(E)
    s = s[:i] + s[j:]
da = [(i, t) for i, t in REIHE if os.path.exists(os.path.join(BASE, "artikel", i + ".html"))]
teile = [A]
for i, _ in da:
    teile.append(open(os.path.join(BASE, "artikel", i + ".html"), encoding="utf-8").read().strip())
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
           '<p><strong>Krankheiten verstehen</strong> · ' + str(zahl) + ' Artikel: Schlaganfall' + ''.join(', ' + t.split(' Typ')[0] for _, t in da) + ' · 52 Krankheiten', s)
open(F, "w", encoding="utf-8").write(s)
print("OK  Artikel im Buch:", ["schlaganfall"] + [i for i, _ in da])
