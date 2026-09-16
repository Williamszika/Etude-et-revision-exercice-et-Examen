#!/usr/bin/env python3
"""Baut zusammenfassungen/index.html — nur die zusammengefassten Kurse und ihre Erklaerungen.

Quelle ist dieselbe Datei wie fuer die Schulungsuebersicht: schulungen/schulungen.json.
Der Unterschied ist, was hier NICHT hineinkommt: keine Quellen-PDFs, keine 110 Kurs-PDFs,
keine Klausurprotokolle. Nur: welcher Kurs, worum geht es, und der Link zum Lesen.

Damit nichts doppelt gepflegt wird, wird beim Hinzufuegen einer Schulung weiterhin nur
schulungen/schulungen.json bearbeitet — diese Seite waechst dann von selbst mit.

    python3 zusammenfassungen/build.py
"""

import json
import os

BASE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(BASE)

# Welche Links sind "lesen und verstehen"? Reihenfolge = Rang.
LESEN = [
    ("zusammenfassung", "Zusammenfassung"),
    ("schulung", "Schulung"),
]
# Alles andere ist Uebung oder Protokoll und steht nur klein daneben.
WEITER = {
    "klausur": "Klausur",
    "faelle": "Übungsfälle",
}

MONATE = ["Januar", "Februar", "März", "April", "Mai", "Juni",
          "Juli", "August", "September", "Oktober", "November", "Dezember"]


def deutsch(iso):
    try:
        j, m, t = iso.split("-")
        return f"{int(t)}. {MONATE[int(m) - 1]} {j}"
    except Exception:
        return iso


def monat(iso):
    try:
        j, m, _ = iso.split("-")
        return f"{MONATE[int(m) - 1]} {j}"
    except Exception:
        return ""


def main():
    quelle = os.path.join(REPO, "schulungen", "schulungen.json")
    daten = json.load(open(quelle, encoding="utf-8"))

    kurse = []
    for s in daten.get("schulungen", []):
        links = s.get("links") or {}

        haupt = None
        for schluessel, etikett in LESEN:
            if links.get(schluessel):
                haupt = {"url": links[schluessel], "label": etikett}
                break
        if not haupt:
            # Ohne Lesestueck gehoert der Kurs nicht auf diese Seite.
            continue

        weiter = [{"url": links[k], "label": v} for k, v in WEITER.items() if links.get(k)]
        # Ein zweites Lesestueck (z. B. Schulung neben Zusammenfassung) zaehlt auch dazu.
        for schluessel, etikett in LESEN:
            if links.get(schluessel) and links[schluessel] != haupt["url"]:
                weiter.insert(0, {"url": links[schluessel], "label": etikett})
        for z in (s.get("zusatz") or []):
            if z.get("url"):
                weiter.append({"url": z["url"], "label": z.get("label", "mehr")})

        kurse.append({
            "titel": s.get("titel", ""),
            "untertitel": s.get("untertitel", ""),
            "worum": s.get("hinweis", ""),
            "fach": s.get("fach", ""),
            "ue": s.get("ue", ""),
            "dozent": s.get("dozent", ""),
            "datum": s.get("datum", ""),
            "datumDe": deutsch(s.get("datum", "")),
            "monat": monat(s.get("datum", "")),
            "icon": s.get("icon", "📄"),
            "kernpunkte": [h for h in (s.get("highlights") or [])][:4],
            "haupt": haupt,
            "weiter": weiter,
        })

    # Die Lernmittel aus "weitere" (Lern-Hub, Klausurprotokoll) sind ebenfalls Lesestoff.
    weitere = []
    for w in daten.get("weitere", []):
        if w.get("link"):
            weitere.append({
                "titel": w.get("titel", ""), "untertitel": w.get("untertitel", ""),
                "worum": w.get("hinweis", ""), "icon": w.get("icon", "📄"),
                "url": w["link"], "datumDe": deutsch(w.get("datum", "")),
            })

    kurse.sort(key=lambda k: k["datum"], reverse=True)

    tpl = open(os.path.join(BASE, "_template.html"), encoding="utf-8").read()
    nutz = json.dumps({"kurse": kurse, "weitere": weitere},
                      ensure_ascii=False).replace("</", "<\\/")
    seite = tpl.replace("__DATA__", nutz)
    ziel = os.path.join(BASE, "index.html")
    open(ziel, "w", encoding="utf-8").write(seite)

    faecher = sorted({k["fach"] for k in kurse if k["fach"]})
    print(f"OK  {len(kurse)} zusammengefasste Kurse, {len(weitere)} weitere Lernmittel "
          f"-> zusammenfassungen/index.html ({round(len(seite)/1024)} KB)")
    print(f"    Fächer: {', '.join(faecher)}")


if __name__ == "__main__":
    main()
