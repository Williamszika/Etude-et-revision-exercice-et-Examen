#!/usr/bin/env python3
"""
Baut schulungen/index.html aus schulungen/schulungen.json.

So fuegst du eine neue Schulung hinzu:
  1. Neuen Eintrag ganz OBEN in die Liste "schulungen" in schulungen.json setzen
     (neueste zuerst) - mit "datum": "JJJJ-MM-TT".
  2. python3 schulungen/build.py
  3. Die Datei schulungen/index.html neu veroeffentlichen -> gleiche URL bleibt.

Genau wie bei "Deutsch taeglich": ein Link, Inhalt waechst mit.
"""
import json
import pathlib

ROOT = pathlib.Path(__file__).resolve().parent
DATA = json.loads((ROOT / "schulungen.json").read_text(encoding="utf-8"))
TPL = (ROOT / "_template.html").read_text(encoding="utf-8")

MONATE = ["Januar", "Februar", "März", "April", "Mai", "Juni",
          "Juli", "August", "September", "Oktober", "November", "Dezember"]


def de_datum(iso):
    y, m, d = iso.split("-")
    return f"{int(d)}. {MONATE[int(m) - 1]} {y}"


def monat_key(iso):
    y, m, _ = iso.split("-")
    return f"{MONATE[int(m) - 1]} {y}"


repo = DATA["repo"].rstrip("/")
branch = DATA["branch"]

schulungen = sorted(DATA["schulungen"], key=lambda s: s["datum"], reverse=True)
for s in schulungen:
    s["datum_de"] = de_datum(s["datum"])
    s["monat"] = monat_key(s["datum"])
    ordner = s["ordner"]
    s["repo_ordner"] = f"{repo}/tree/{branch}/{ordner}"
    for q in s.get("quellen", []):
        q["url"] = f"{repo}/blob/{branch}/{ordner}/quellen/{q['datei']}"
    for f in s.get("dateien", []):
        f["url"] = f"{repo}/blob/{branch}/{ordner}/{f['datei']}"

weitere = sorted(DATA["weitere"], key=lambda w: w["datum"], reverse=True)
for w in weitere:
    w["datum_de"] = de_datum(w["datum"])
    w["repo_ordner"] = f"{repo}/tree/{branch}/{w['ordner']}"

# Alle Kurs-PDFs — erzeugt von kurs-pdfs-bauen.py, hier nur verlinkt
kurs = {"gruppen": [], "anzahl": 0, "anzahl_aa": 0}
kurs_datei = ROOT / "kurs-pdfs.json"
if kurs_datei.exists():
    kurs = json.loads(kurs_datei.read_text(encoding="utf-8"))
    for g in kurs["gruppen"]:
        for d in g["dateien"]:
            d["url"] = f"{repo}/blob/{branch}/{d['pfad']}"

payload = {
    "schulungen": schulungen,
    "weitere": weitere,
    "kurs": kurs,
    "faecher": sorted({s["fach"] for s in schulungen}),
    "anzahl_pdf": sum(len(s.get("quellen", [])) for s in schulungen),
    "stand": max(s["datum"] for s in schulungen),
    "stand_de": de_datum(max(s["datum"] for s in schulungen)),
}

blob = json.dumps(payload, ensure_ascii=False).replace("</", "<\\/")
out = TPL.replace("__DATA__", blob)
(ROOT / "index.html").write_text(out, encoding="utf-8")
print(f"OK  {len(schulungen)} Schulungen, {len(weitere)} weitere Lernmittel, "
      f"{payload['anzahl_pdf']} Quellen-PDFs, {kurs['anzahl']} Kurs-PDFs "
      f"({kurs['anzahl_aa']} Arbeitsaufträge) -> schulungen/index.html")
