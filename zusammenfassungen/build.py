#!/usr/bin/env python3
"""Baut zusammenfassungen/index.html — NUR die Zusammenfassungen, sonst nichts.

Quelle ist dieselbe Datei wie fuer die frueher veroeffentlichte Schulungsuebersicht:
schulungen/schulungen.json. Der Unterschied ist, was hier NICHT hineinkommt.

Ihre Ansage vom 16.09.2026: "Sicher sein, dass sie erhaelt nur die Zusammenfassung."
Daraus die Regel, und sie ist bewusst hart:

    Pro Kurs GENAU EIN Link — das Lesestueck.

Drin:    links.zusammenfassung, sonst links.schulung (die erklaerte Seite des Kurses)
Draussen: links.klausur und links.faelle (Uebungen und Protokolle, keine Zusammenfassung)
          zusatz (Gespraechsleitfaeden, Fallbeispiele — Arbeitsmaterial, keine Zusammenfassung)
          Quellen-PDFs, Kurs-PDFs, Dateilisten
          aus "weitere" alles, was kein Lesestoff ist (z. B. das Klausur-Protokoll)

Damit nichts doppelt gepflegt wird, wird beim Hinzufuegen einer Schulung weiterhin nur
schulungen/schulungen.json bearbeitet — diese Seite waechst dann von selbst mit.

    python3 zusammenfassungen/build.py
"""

import datetime
import json
import os

BASE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(BASE)

# --- Neuanfang am 16.09.2026 -------------------------------------------------------------
# Ihre Entscheidung an diesem Tag: die Seite faengt bei heute neu an und zeigt nur noch die
# Kurse, deren PDFs sie mir gibt. Erster Eintrag der neuen Etappe: Asthma bronchiale.
#
# WICHTIG: Hier wird NICHTS geloescht. Die siebzehn frueheren Eintraege stehen unveraendert
# in schulungen/schulungen.json, und ihre Artifact-Seiten sind weiterhin online — sie werden
# von dieser Liste nur nicht mehr angezeigt. Will sie sie zurueck, genuegt es, NEUSTART
# hier wieder nach vorn zu setzen. Nichts muss neu geschrieben werden.
NEUSTART = "2026-09-16"

# Nur diese beiden zaehlen als Zusammenfassung. Reihenfolge = Rang.
LESEN = [
    ("zusammenfassung", "Zusammenfassung"),
    ("schulung", "Schulung"),
]

# Aus dem Abschnitt "weitere" kommt nur herein, was wirklich Zusammenfassungen sammelt.
# Das Klausur-Protokoll ist eine Auswertung geschriebener Klausuren, keine Zusammenfassung.
WEITERE_ERLAUBT = {"lernhub"}

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
    draussen = []
    vor_neustart = 0
    heute = datetime.date.today().isoformat()
    for s in daten.get("schulungen", []):
        datum = s.get("datum", "")

        # Vor dem Neustart? Dann nicht anzeigen — aber auch nicht anfassen.
        # Ein Datum in der Zukunft ist ein Termin (z. B. die Zwischenpruefung), kein
        # Tag, an dem eine Zusammenfassung dazugekommen ist.
        if not (NEUSTART <= datum <= heute):
            vor_neustart += 1
            continue

        links = s.get("links") or {}

        haupt = None
        for schluessel, etikett in LESEN:
            if links.get(schluessel):
                haupt = {"url": links[schluessel], "label": etikett}
                break
        if not haupt:
            # Ohne Lesestueck gehoert der Kurs nicht auf diese Seite.
            continue

        # Alles andere bleibt draussen — nur mitzaehlen, damit der Build es berichtet.
        for k, v in (("klausur", "Klausur"), ("faelle", "Übungsfälle")):
            if links.get(k):
                draussen.append(f"{s.get('titel','')}: {v}")
        for z in (s.get("zusatz") or []):
            if z.get("url"):
                draussen.append(f"{s.get('titel','')}: {z.get('label','Zusatz')}")

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
            "weiter": [],
        })

    # Aus "weitere" nur, was selbst Zusammenfassungen sammelt.
    weitere = []
    for w in daten.get("weitere", []):
        if not w.get("link"):
            continue
        if w.get("id") not in WEITERE_ERLAUBT:
            draussen.append(f"weitere: {w.get('titel','')}")
            continue
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
    if vor_neustart:
        print(f"    {vor_neustart} Eintrag/Eintraege vor dem Neustart {NEUSTART} — "
              f"stehen weiter in schulungen.json, werden nur nicht gezeigt")
    print(f"OK  {len(kurse)} Zusammenfassungen, {len(weitere)} weitere "
          f"-> zusammenfassungen/index.html ({round(len(seite)/1024)} KB)")
    print(f"    Fächer: {', '.join(faecher)}")
    if draussen:
        print(f"    draußen gelassen ({len(draussen)}), weil keine Zusammenfassung:")
        for d in draussen:
            print(f"      · {d}")


if __name__ == "__main__":
    main()
