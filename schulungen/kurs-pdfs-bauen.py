#!/usr/bin/env python3
"""Erzeugt schulungen/kurs-pdfs.json — die vollständige Liste aller Kurs-PDFs.

Quelle der Zuordnung ist ausschliesslich das Repo selbst:
  * Wissen/00-themenkarte.md  — welche Datei zu welchem der 13 Themen gehoert
  * Wissen/<datei>.md         — Zeile "## Quelle: PDFs/<datei>.pdf", Titel und Dokumenttyp

Nichts wird geraten: Titel, Kurskennung (CE/UE) und die Einstufung als Arbeitsauftrag
stammen aus den Wissen-Dateien. Aufruf:

    python3 schulungen/kurs-pdfs-bauen.py
"""

import json
import pathlib
import re
import sys

BASE = pathlib.Path(__file__).resolve().parent.parent
WISSEN = BASE / "Wissen"
KARTE = WISSEN / "00-themenkarte.md"
PDFDIR = BASE / "PDFs"
ZIEL = BASE / "schulungen" / "kurs-pdfs.json"

ICONS = {1: "👁️", 2: "🧠", 3: "🌡️", 4: "🩹", 5: "🚶", 6: "🦴", 7: "❤️",
         8: "💧", 9: "🚽", 10: "🍽️", 11: "💉", 12: "🪥", 13: "📋"}

# Zwei Dateien nennt die Themenkarte nicht namentlich — hier nachgetragen.
NACHTRAG = {"PDFs/17-rasur-und-bartpflege.pdf": 12,
            "PDFs/67-bettlaegerigkeit-fuenf-phasen-praevention.pdf": 5}

# Arbeitsauftrag → das Dokument, auf das er sich bezieht (nur belegte Paare).
GEHOERT_ZU = {
    "PDFs/86-arbeitsauftrag-suprapubische-harndrainage.pdf": "03-suprapubische-harndrainage.pdf",
    "PDFs/87-arbeitsauftrag-bart-rasurpflege.pdf": "17-rasur-und-bartpflege.pdf",
    "PDFs/96-aa-aspirationsprophylaxe.pdf": "81-aspirationsprophylaxe.pdf",
    "PDFs/99-aa-prozess-bettlaegerigwerden.pdf": "67-bettlaegerigkeit-fuenf-phasen-praevention.pdf",
    "PDFs/101-aa-munderkrankungen.pdf": "107-mund-und-zahnpflege.pdf",
}

AA_MUSTER = re.compile(r"(arbeitsauftrag|/\d+-aa-|/aa[_-])", re.I)
CE_MUSTER = re.compile(r"\bCE\s?0?(\d+[AB]?)\s*[,/ ]\s*UE\s?0?(\d+)", re.I)


def wissen_info():
    """PDF-Pfad -> {titel, ce, aa, md} aus den Wissen-Dateien."""
    info = {}
    for p in sorted(WISSEN.glob("*.md")):
        text = p.read_text(encoding="utf-8")
        q = re.search(r"^## Quelle:\s*(\S+)", text, re.M)
        if not q:
            continue
        src = q.group(1)
        titel = text.split("\n", 1)[0].lstrip("# ").strip()
        ce = CE_MUSTER.search(text)
        eintrag = info.setdefault(src, {"titel": titel, "ce": "", "aa": False, "md": []})
        # Der laengere Titel ist meist der vollstaendigere.
        if len(titel) > len(eintrag["titel"]):
            eintrag["titel"] = titel
        if ce and not eintrag["ce"]:
            eintrag["ce"] = f"CE {ce.group(1)} UE {ce.group(2)}"
        if AA_MUSTER.search(src) or re.search(r"^## Dokumenttyp\n\s*Arbeitsauftrag", text, re.M):
            eintrag["aa"] = True
        eintrag["md"].append(p.name)
    return info


def themen_aus_karte():
    """Themennummer -> {titel, dateien:[Wissen-md]}"""
    text = KARTE.read_text(encoding="utf-8")
    themen = {}
    for teil in text.split("\n## ")[1:]:
        kopf = teil.split("\n", 1)[0].strip()
        m = re.match(r"(\d+)\.\s+(.*)", kopf)
        if not m:
            continue
        themen[int(m.group(1))] = {
            "titel": m.group(2).strip(),
            "md": re.findall(r"^- ([0-9]{3}-\S+\.md)", teil, re.M),
        }
    return themen


def main() -> int:
    if not KARTE.exists():
        print(f"fehlt: {KARTE}", file=sys.stderr)
        return 1

    info = wissen_info()
    themen = themen_aus_karte()

    # Wissen-md -> PDF-Pfad
    md_zu_pdf = {}
    for src, e in info.items():
        for md in e["md"]:
            md_zu_pdf[md] = src

    gruppen, gesehen = [], set()
    for nr in sorted(themen):
        dateien = []
        for md in themen[nr]["md"]:
            src = md_zu_pdf.get(md)
            if not src or not src.startswith("PDFs/") or src in gesehen:
                continue
            gesehen.add(src)
            dateien.append(src)
        # Nachtraege dieses Themas anhaengen
        for src, ziel in NACHTRAG.items():
            if ziel == nr and src not in gesehen:
                gesehen.add(src)
                dateien.append(src)

        eintraege = []
        for src in dateien:
            e = info.get(src, {})
            pfad, nur_text = src, False
            if not (BASE / src).exists():
                # Tafelbilder und Ähnliches liegen nur als Textfassung in Wissen/
                md = e.get("md", [])
                if md and (WISSEN / md[0]).exists():
                    pfad, nur_text = f"Wissen/{md[0]}", True
            eintraege.append({
                "datei": pathlib.Path(src).name,
                "pfad": pfad,
                "titel": e.get("titel") or pathlib.Path(src).stem,
                "ce": e.get("ce", ""),
                "aa": bool(e.get("aa")),
                "gehoert_zu": GEHOERT_ZU.get(src, ""),
                "nur_text": nur_text,
                "fehlt": not (BASE / pfad).exists(),
            })
        # Arbeitsauftraege direkt hinter das Dokument sortieren, zu dem sie gehoeren
        nach_datei = {x["datei"]: x for x in eintraege}
        geordnet, erledigt = [], set()
        for x in eintraege:
            if x["datei"] in erledigt or x["aa"]:
                continue
            geordnet.append(x)
            erledigt.add(x["datei"])
            for y in eintraege:
                if y["aa"] and y["gehoert_zu"] == x["datei"] and y["datei"] not in erledigt:
                    geordnet.append(y)
                    erledigt.add(y["datei"])
        for x in eintraege:  # uebrige Arbeitsauftraege ohne zugeordnetes Dokument
            if x["datei"] not in erledigt:
                geordnet.append(x)
                erledigt.add(x["datei"])
        assert len(geordnet) == len(eintraege), (nr, len(geordnet), len(eintraege))
        del nach_datei

        gruppen.append({"nr": nr, "titel": themen[nr]["titel"],
                        "icon": ICONS.get(nr, "📄"), "dateien": geordnet})

    # Was im Ordner liegt, aber in keiner Gruppe steht
    alle = {f"PDFs/{p.name}" for p in PDFDIR.glob("*.pdf")}
    offen = sorted(alle - gesehen)

    # Arbeitsauftrag ohne zugehöriges Quelldokument — bewusst sichtbar halten
    verwaist = []
    for p in sorted((BASE / "PDFs-neu").glob("*.pdf")):
        verwaist.append({"datei": p.name, "pfad": f"PDFs-neu/{p.name}",
                         "titel": p.stem.replace("_", " "), "ce": "", "aa": True,
                         "gehoert_zu": "", "nur_text": False, "fehlt": False})
    if verwaist:
        gruppen.append({"nr": 14, "titel": "Arbeitsaufträge ohne Quelldokument",
                        "icon": "❓", "dateien": verwaist})

    daten = {
        "_hinweis": "Erzeugt von schulungen/kurs-pdfs-bauen.py aus Wissen/00-themenkarte.md "
                    "und den Wissen-Dateien. Nicht von Hand bearbeiten.",
        "gruppen": gruppen,
        "ohne_thema": offen,
        "anzahl": sum(len(g["dateien"]) for g in gruppen),
        "anzahl_aa": sum(1 for g in gruppen for d in g["dateien"] if d["aa"]),
    }
    ZIEL.write_text(json.dumps(daten, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"{daten['anzahl']} PDFs in {len(gruppen)} Themen, davon {daten['anzahl_aa']} "
          f"Arbeitsaufträge -> {ZIEL.name}")
    if offen:
        print("ohne Thema:", offen)
    fehlend = [d["pfad"] for g in gruppen for d in g["dateien"] if d["fehlt"]]
    if fehlend:
        print("in der Karte genannt, aber nicht im Ordner:", fehlend)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
