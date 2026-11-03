#!/usr/bin/env python3
"""Baut bibliothek/index.html — EIN Link mit beiden Büchern, geschlossen auf dem Tisch.

Ihr Wunsch vom 03.11.2026: ein einziger Link mit „Meine Kurse, zusammengefasst“ und „Krankheiten
verstehen“; die Bücher liegen zu, ein Klick schlägt eines langsam auf, man kann es wieder zuklappen,
und beim nächsten Öffnen geht es dort weiter, wo sie war.

Nichts wird doppelt gepflegt: Die Seite wird aus den beiden fertigen Büchern zusammengesetzt.
    krankheiten/index.html          (von Hand gepflegt)
    zusammenfassungen/index.html    (aus zusammenfassungen/build.py)
Jedes Buch bekommt einen eigenen Rahmen (#kh, #zf); seine Styles werden darauf eingegrenzt.
Die Skripte der Bücher erkennen window.BIBLIOTHEK und warten dann, bis das Regal sie öffnet.

    python3 bibliothek/build.py
"""
import os
import re

BASE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(BASE)


def teile(html):
    i = html.index("<style>"); j = html.index("</style>", i)
    k = html.index("<script>", j); m = html.rindex("</script>")
    return {"css": html[i + 7:j], "body": html[j + 8:k], "js": html[k + 8:m]}


def selektoren(sel):
    out, tiefe, akt = [], 0, ""
    for ch in sel:
        if ch in "([": tiefe += 1
        elif ch in ")]": tiefe -= 1
        if ch == "," and tiefe == 0:
            out.append(akt); akt = ""
        else:
            akt += ch
    out.append(akt)
    return [x.strip() for x in out if x.strip()]


def eingrenzen(sel, root):
    neu = []
    for x in selektoren(sel):
        x = re.sub(r"^:root(\[[^\]]*\]|:not\([^)]*\))*", root, x)
        x = re.sub(r"^html\.buch-an\s+body\b", root, x)
        x = re.sub(r"^html(\.buch-an)?\b", root, x)
        x = re.sub(r"^body\b", root, x)
        if x.startswith(root):
            rest = x[len(root):]
            x = root + rest
        elif x == "*":
            x = root + " *"
        else:
            x = root + " " + x
        neu.append(x)
    # doppelte entfernen (aus „html.buch-an,html.buch-an body“ wird zweimal root)
    gesehen = []
    for x in neu:
        if x not in gesehen: gesehen.append(x)
    return ",".join(gesehen)


def css_eingrenzen(css, root):
    css = re.sub(r"/\*.*?\*/", "", css, flags=re.S)
    out, i, n = [], 0, len(css)
    while i < n:
        k = css.find("{", i)
        if k < 0: break
        kopf = css[i:k].strip()
        if kopf.startswith("@media") or kopf.startswith("@supports"):
            tiefe, e = 1, k + 1
            while tiefe:
                if css[e] == "{": tiefe += 1
                elif css[e] == "}": tiefe -= 1
                e += 1
            out.append(kopf + "{" + css_eingrenzen(css[k + 1:e - 1], root) + "}")
            i = e; continue
        e = css.index("}", k)
        if kopf.startswith("@"):
            out.append(css[i:e + 1].strip())
        else:
            out.append(eingrenzen(kopf, root) + "{" + css[k + 1:e] + "}")
        i = e + 1
    return "\n".join(out)


def main():
    kh = teile(open(os.path.join(REPO, "krankheiten", "index.html"), encoding="utf-8").read())
    zf = teile(open(os.path.join(REPO, "zusammenfassungen", "index.html"), encoding="utf-8").read())
    tpl = open(os.path.join(BASE, "_regal.html"), encoding="utf-8").read()
    seite = (tpl.replace("/*__KH_CSS__*/", css_eingrenzen(kh["css"], "#kh"))
                .replace("/*__ZF_CSS__*/", css_eingrenzen(zf["css"], "#zf"))
                .replace("<!--__KH_BODY__-->", kh["body"])
                .replace("<!--__ZF_BODY__-->", zf["body"])
                .replace("/*__KH_JS__*/", kh["js"])
                .replace("/*__ZF_JS__*/", zf["js"]))
    ziel = os.path.join(BASE, "index.html")
    open(ziel, "w", encoding="utf-8").write(seite)
    print(f"OK  bibliothek/index.html ({round(len(seite.encode('utf-8')) / 1024)} KB) — Krankheiten verstehen + Meine Kurse")


if __name__ == "__main__":
    main()
